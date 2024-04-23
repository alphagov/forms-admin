class MakeFormLiveService
  class << self
    def call(**args)
      new(**args)
    end
  end

  def initialize(current_form:, current_user:)
    @current_form = current_form
    @current_live_form = Form.find_live(current_form.id) if current_form.is_live?
    @current_user = current_user
  end

  def make_live
    @current_form.make_live!

    if FeatureService.enabled?(:notify_original_submission_email_of_change) && live_form_submission_email_has_changed
      SubmissionEmailMailer.alert_email_change(
        live_email: @current_live_form.submission_email,
        form_name: @current_live_form.name,
        current_user: @current_user,
      ).deliver_now
    end

    true
  end

  def page_title
    return I18n.t("page_titles.your_form_is_live") if @current_form.is_archived?
    return I18n.t("page_titles.your_changes_are_live") if @current_form.is_live?

    I18n.t("page_titles.your_form_is_live")
  end

private

  def live_form_submission_email_has_changed
    @current_form.is_live? && @current_live_form.submission_email != @current_form.submission_email
  end
end
