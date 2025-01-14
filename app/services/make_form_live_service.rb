class MakeFormLiveService
  class << self
    def call(**args)
      new(**args)
    end
  end

  def initialize(current_form:, current_user:)
    @current_form = current_form
    @current_live_form = FormRepository.find_live(form_id: current_form.id) if current_form.is_live?
    @current_user = current_user
  end

  def make_live
    FormRepository.make_live!(@current_form)

    if live_form_submission_email_has_changed
      SubmissionEmailMailer.alert_email_change(
        live_email: @current_live_form.submission_email,
        form_name: @current_live_form.name,
        creator_name: @current_user.name,
        creator_email: @current_user.email,
      ).deliver_now
    end
  end

  def page_title
    return I18n.t("page_titles.your_form_is_live") if @current_form.is_archived?
    return I18n.t("page_titles.your_changes_are_live") if @current_form.is_live?

    I18n.t("page_titles.your_form_is_live")
  end

  def confirmation_page_body
    return I18n.t("make_changes_live.confirmation.body_html").html_safe if @current_form.is_live?

    I18n.t("make_live.confirmation.body_html").html_safe
  end

private

  def live_form_submission_email_has_changed
    @current_form.is_live? && @current_live_form.submission_email != @current_form.submission_email
  end
end
