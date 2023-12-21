class MakeFormLiveService
  class << self
    def call(**args)
      new(**args)
    end
  end

  def initialize(draft_form:, current_user:)
    @draft_form = draft_form
    @current_live_form = Form.find_live(draft_form.id) if draft_form.has_live_version
    @current_user = current_user
  end

  def make_live
    @draft_form.make_live!

    if live_form_submission_email_has_changed
      SubmissionEmailMailer.notify_submission_email_has_changed(
        live_email: @current_live_form.submission_email,
        form_name: @current_live_form.name,
        current_user: @current_user,
      ).deliver_now
    end

    true
  end

  def page_title
    if @draft_form.has_live_version
      I18n.t("page_titles.your_changes_are_live")
    else
      I18n.t("page_titles.your_form_is_live")
    end
  end

private

  def live_form_submission_email_has_changed
    @draft_form.has_live_version && @current_live_form.submission_email != @draft_form.submission_email
  end
end
