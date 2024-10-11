class EmailTaskStatusService
  def initialize(form:)
    @form = form
  end

  def ready_for_live?
    incomplete_email_tasks.empty?
  end

  def incomplete_email_tasks
    {
      missing_submission_email: submission_email_status,
    }.reject { |_k, v| v == :completed }.map { |k, _v| k }
  end

  def email_task_statuses
    {
      submission_email_status:,
      confirm_submission_email_status:,
    }
  end

private

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
end
