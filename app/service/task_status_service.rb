class TaskStatusService
  def initialize(form:)
    @form = form
  end

  def name_status
    :completed
  end

  def pages_status
    if @form.question_section_completed && @form.pages.any?
      :completed
    elsif @form.pages.any?
      :in_progress
    else
      :not_started
    end
  end

  def declaration_status
    if @form.declaration_section_completed
      :completed
    elsif @form.declaration_text.present?
      :in_progress
    else
      :not_started
    end
  end

  def what_happens_next_status
    if @form.what_happens_next_text.present?
      :completed
    else
      :not_started
    end
  end

  def submission_email_status
    {
      email_set_without_confirmation: :completed,
      not_started: :not_started,
      sent: :in_progress,
      confirmed: :completed,
    }[@form.email_confirmation_status]
  end

  def confirm_submission_email_status
    {
      email_set_without_confirmation: :completed,
      not_started: :cannot_start,
      sent: :not_started,
      confirmed: :completed,
    }[@form.email_confirmation_status]
  end

  def privacy_policy_status
    if @form.privacy_policy_url.present?
      :completed
    else
      :not_started
    end
  end

  def support_contact_details_status
    if @form.support_email.present? || @form.support_phone.present? || (@form.support_url_text.present? && @form.support_url)
      :completed
    else
      :not_started
    end
  end

  def make_live_status
    return nil if @form.has_live_version
    return :not_started if mandatory_tasks_completed?

    :cannot_start
  end

  def mandatory_tasks_completed?
    missing_sections.empty?
  end

  def missing_sections
    { missing_pages: pages_status,
      missing_what_happens_next: what_happens_next_status,
      missing_submission_email: submission_email_status,
      missing_privacy_policy_url: privacy_policy_status,
      missing_contact_details: support_contact_details_status }.reject { |_k, v| v == :completed }.map { |k, _v| k }
  end

  def task_statuses
    {
      name_status:,
      pages_status:,
      declaration_status:,
      what_happens_next_status:,
      submission_email_status:,
      confirm_submission_email_status:,
      privacy_policy_status:,
      support_contact_details_status:,
      make_live_status:,
    }
  end
end
