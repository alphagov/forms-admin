class GroupFormsMoveMailer < GovukNotifyRails::Mailer
  def form_moved_email_org_admin(...)
    set_template(Settings.govuk_notify.group_form_moved_org_admin_template_id)

    form_moved_email(...)
  end

  def form_moved_email_group_admin(...)
    set_template(Settings.govuk_notify.group_form_moved_group_admin_editor_template_id)

    form_moved_email(...)
  end

  def form_moved_email(to_email:, form_name:, old_group_name:, new_group_name:, org_admin_email:, org_admin_name:)
    set_personalisation(
      form_name:,
      old_group_name:,
      new_group_name:,
      org_admin_email:,
      org_admin_name:,
    )

    mail(to: to_email)
  end
end
