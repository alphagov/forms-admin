class GroupUpgradedMailer < GovukNotifyRails::Mailer
  def group_upgraded_email(upgraded_by_user:, to_email:, group:, group_url:)
    set_template(Settings.govuk_notify.group_upgraded_template_id)

    set_email_reply_to(Settings.govuk_notify.zendesk_reply_to_id)

    set_personalisation(
      upgraded_by_name: upgraded_by_user.name,
      group_name: group.name,
      group_url:,
    )

    mail(to: to_email)
  end
end
