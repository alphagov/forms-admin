class TaskStatusService
  def initialize(form:)
    @form = form
  end

  def mandatory_tasks_completed?
    incomplete_tasks.empty?
  end

  def incomplete_tasks
    { missing_pages: pages_status,
      missing_what_happens_next: what_happens_next_status,
      missing_privacy_policy_url: privacy_policy_status,
      missing_contact_details: support_contact_details_status,
      share_preview_not_completed: share_preview_status }.reject { |_k, v| v == :completed }.map { |k, _v| k }
  end

  def task_statuses
    {
      name_status:,
      pages_status:,
      declaration_status:,
      what_happens_next_status:,
      payment_link_status:,
      privacy_policy_status:,
      support_contact_details_status:,
      receive_csv_status:,
      share_preview_status:,
      make_live_status:,
    }
  end

private

  def name_status
    :completed
  end

  def pages_status
    return :completed if @form.question_section_completed && @form.pages.any?
    return :in_progress if @form.pages.any?

    :not_started
  end

  def declaration_status
    return :completed if @form.declaration_section_completed
    return :in_progress if @form.declaration_text.present?

    :not_started
  end

  def what_happens_next_status
    return :completed if @form.what_happens_next_markdown.present?

    :not_started
  end

  def payment_link_status
    return :completed if @form.payment_url.present?

    :optional
  end

  def privacy_policy_status
    return :completed if @form.privacy_policy_url.present?

    :not_started
  end

  def support_contact_details_status
    return :completed if @form.support_email.present? || @form.support_phone.present? || (@form.support_url_text.present? && @form.support_url)

    :not_started
  end

  def receive_csv_status
    return :completed if @form.email_with_csv?

    :optional
  end

  def share_preview_status
    return :cannot_start unless @form.pages.any?
    return :completed if @form.share_preview_completed?

    :not_started
  end

  def make_live_status
    return make_live_status_for_draft if @form.has_draft_version
    return :not_started if @form.has_been_archived

    :completed if @form.has_live_version
  end

  def make_live_status_for_draft
    mandatory_tasks_completed? ? :not_started : :cannot_start
  end
end
