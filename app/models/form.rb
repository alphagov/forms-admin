class Form < ActiveResource::Base
  self.site = "#{Settings.forms_api.base_url}/api/v1"
  self.include_format_in_path = false
  headers["X-API-Token"] = ENV["API_KEY"]

  STATUSES = { draft: "draft", live: "live" }.freeze

  has_many :pages

  attr_accessor :missing_sections

  def last_page
    pages.find { |p| !p.has_next_page? }
  end

  def live?
    live_at.present? && live_at < Time.zone.now
  end

  def draft?
    !live?
  end

  def status
    return STATUSES[:live] if live?

    STATUSES[:draft]
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
    @missing_sections << :missing_pages unless pages.any?
    @missing_sections << :missing_submission_email if submission_email.blank?
    @missing_sections << :missing_privacy_policy_url if privacy_policy_url.blank?

    if @missing_sections.any?
      false
    else
      true
    end
  end
end
