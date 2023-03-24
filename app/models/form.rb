class Form < ActiveResource::Base
  self.site = "#{Settings.forms_api.base_url}/api/v1"
  self.include_format_in_path = false
  headers["X-API-Token"] = Settings.forms_api.auth_key

  has_many :pages

  attr_accessor :missing_sections

  def self.find_live(id)
    find(:one, from: "#{prefix}forms/#{id}/live")
  end

  def last_page
    pages.find { |p| !p.has_next_page? }
  end

  def live?
    live_at.present? && live_at < Time.zone.now
  end

  def status
    live? ? :live : :draft
  end

  def save_page(page)
    page.save && append_page(page)
  end

  def append_page(page)
    return true if pages.empty?

    # if there is already a last page, set its next_page value to our new page. This
    # should probably be done in the API, here we cannot add a page and set
    # the next_page value atomically
    current_last_page = last_page
    current_last_page.next_page = page.id
    current_last_page.save!
  end

  def ready_for_live?
    @missing_sections = []

    task_list_statuses = TaskStatusService.new(form: self)
    @missing_sections << :missing_pages unless task_list_statuses.pages_status == :completed
    @missing_sections << :missing_submission_email unless task_list_statuses.submission_email_status == :completed
    @missing_sections << :missing_privacy_policy_url unless task_list_statuses.privacy_policy_status == :completed
    @missing_sections << :missing_contact_details unless task_list_statuses.support_contact_details_status == :completed
    @missing_sections << :missing_what_happens_next unless task_list_statuses.what_happens_next_status == :completed

    if @missing_sections.any?
      false
    else
      true
    end
  end

  def make_live!
    post "make-live"
  end

  def form_submission_email
    FormSubmissionEmail.find_by_form_id(id)
  end

  def email_confirmation_status
    # Email set before confirmation feature introduced
    return :email_set_without_confirmation if submission_email.present? && form_submission_email.blank?

    if form_submission_email.present?
      if form_submission_email.confirmed? || submission_email == form_submission_email.temporary_submission_email
        :confirmed
      else
        :sent
      end
    else
      :not_started
    end
  end

  def page_number(page)
    return pages.length + 1 if page.nil?

    index = pages.index { |existing_page| existing_page.attributes == page.attributes }
    (index.nil? ? pages.length : index) + 1
  end
end
