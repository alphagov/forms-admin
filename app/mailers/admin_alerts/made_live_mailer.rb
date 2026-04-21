class AdminAlerts::MadeLiveMailer < GovukNotifyRails::Mailer
  include Rails.application.routes.url_helpers
  def new_draft_form_made_live(form:, user:, to_email:)
    set_template(Settings.govuk_notify.admin_alerts.new_draft_form_made_live_template_id)
    send_mail(to_email:, personalisation: {
      form_name: form.name,
      form_link: live_form_url(form),
      user_name: user.name,
      user_email: user.email,
    })
  end

  def live_form_changes_made_live(form:, user:, to_email:)
    set_template(Settings.govuk_notify.admin_alerts.live_form_changes_made_live_template_id)
    send_mail(to_email:, personalisation: {
      form_name: form.name,
      form_link: live_form_url(form),
      user_name: user.name,
      user_email: user.email,
    })
  end

  def archived_form_changes_made_live(form:, user:, to_email:)
    set_template(Settings.govuk_notify.admin_alerts.archived_form_changes_made_live_template_id)
    send_mail(to_email:, personalisation: {
      form_name: form.name,
      form_link: live_form_url(form),
      user_name: user.name,
      user_email: user.email,
    })
  end

  def copied_form_made_live(form:, copied_from_form:, user:, to_email:)
    set_template(Settings.govuk_notify.admin_alerts.copied_form_made_live_template_id)
    send_mail(to_email:, personalisation: {
      form_name: form.name,
      form_link: live_form_url(form),
      copied_from_form_name: copied_from_form.name,
      copied_from_form_link: form_url(copied_from_form),
      user_name: user.name,
      user_email: user.email,
    })
  end

  def archived_form_made_live(form:, user:, to_email:)
    set_template(Settings.govuk_notify.admin_alerts.archived_form_made_live_template_id)
    send_mail(to_email:, personalisation: {
      form_name: form.name,
      form_link: live_form_url(form),
      user_name: user.name,
      user_email: user.email,
    })
  end

private

  def send_mail(to_email:, personalisation:)
    set_personalisation(**personalisation)

    mail(to: to_email)
  end
end
