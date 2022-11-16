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
    if FeatureService.enabled?(:submission_email_confirmation)
      {
        email_set_without_confirmation: :completed,
        not_started: :not_started,
        sent: :in_progress,
        confirmed: :completed,
      }[@form.email_confirmation_status]
    # without submission_email_confirmation feature
    elsif @form.submission_email.present?
      :completed
    else
      :not_started
    end
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
    if mandatory_tasks_completed?
      :not_started
    else
      :cannot_start
    end
  end

  def mandatory_tasks_completed?
    [pages_status,
     what_happens_next_status,
     submission_email_status,
     privacy_policy_status,
     support_contact_details_status].all? { |task| task == :completed }
  end

  def can_enter_submission_email_code
    @form.email_confirmation_status == :sent
  end
end
