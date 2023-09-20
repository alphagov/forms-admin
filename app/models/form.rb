class Form < ActiveResource::Base
  self.site = "#{Settings.forms_api.base_url}/api/v1"
  self.include_format_in_path = false
  headers["X-API-Token"] = Settings.forms_api.auth_key

  belongs_to :organisation
  has_many :pages

  def self.find_live(id)
    find(:one, from: "#{prefix}forms/#{id}/live")
  end

  def qualifying_route_pages
    pages.filter { |p| p.answer_type == "selection" && p.answer_settings.only_one_option == "true" && p.position != pages.length && p.conditions.empty? }
  end

  def has_no_remaining_routes_available?
    qualifying_route_pages.none? && has_routing_conditions
  end

  def status
    has_live_version ? :live : :draft
  end

  def ready_for_live?
    task_status_service.mandatory_tasks_completed?
  end

  delegate :missing_sections, to: :task_status_service

  delegate :task_statuses, to: :task_status_service

  def make_live!
    post "make-live"
  end

  def self.update_organisation_for_creator(creator_id, organisation_id)
    if creator_id.present? && organisation_id.present?
      patch("update-organisation-for-creator", creator_id:, organisation_id:)
    end
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

private

  def has_routing_conditions
    pages.filter { |p| p.conditions.any? }.any?
  end

  def task_status_service
    @task_status_service ||= TaskStatusService.new(form: self)
  end
end
