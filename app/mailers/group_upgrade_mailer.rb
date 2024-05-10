class GroupUpgradeMailer < GovukNotifyRails::Mailer
  def upgraded_email(to_email:, upgraded_by_name:, group_name:, group_url:)
    set_template(Settings.govuk_notify.group_upgraded_template_id)

    set_email_reply_to(Settings.govuk_notify.zendesk_reply_to_id)

    set_personalisation(
      upgraded_by_name:,
      group_name:,
      group_url:,
    )

    mail(to: to_email)
  end

  def rejected_email(to_email:, rejected_by_name:, rejected_by_email:, group_name:, group_url:)
    set_template(Settings.govuk_notify.group_upgrade_rejected_template_id)

    set_email_reply_to(Settings.govuk_notify.zendesk_reply_to_id)

    set_personalisation(
      rejected_by_name:,
      rejected_by_email:,
      group_name:,
      group_url:,
    )

    mail(to: to_email)
  end

  def requested_email(to_email:, requester_name:, requester_email_address:, group_name:, view_request_url:)
    set_template(Settings.govuk_notify.group_upgrade_requested_template_id)

    set_email_reply_to(Settings.govuk_notify.zendesk_reply_to_id)

    set_personalisation(
      requester_name:,
      requester_email_address:,
      group_name:,
      view_request_url:,
    )

    mail(to: to_email)
  end
end
