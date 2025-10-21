class GroupDeleteMailer < GovukNotifyRails::Mailer
  def group_deleted_email_org_admin(...)
    set_template(Settings.govuk_notify.group_deleted_org_admin_template_id)

    group_deleted_email(...)
  end

  def group_deleted_email_group_admins_and_editors(...)
    set_template(Settings.govuk_notify.group_deleted_group_admin_editor_template_id)

    group_deleted_email(...)
  end

  def group_deleted_email(to_email:, group_name:, org_admin_email_address:, org_admin_name:)
    set_personalisation(
      group_name:,
      org_admin_email_address:,
      org_admin_name:,
    )

    mail(to: to_email)
  end
end
