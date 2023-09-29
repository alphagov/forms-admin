class UserUpgradeRequestMailer < GovukNotifyRails::Mailer
  def upgrade_request_email(user_email:)
    set_template(Settings.govuk_notify.user_upgrade_template_id)

    set_email_reply_to(Settings.govuk_notify.zendesk_reply_to_id)

    mail(to: user_email)
  end
end
