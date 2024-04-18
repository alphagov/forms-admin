class GroupMemberMailer < GovukNotifyRails::Mailer
  def added_to_group(membership, group_url:)
    set_template(Settings.govuk_notify.group_member_added_to_group_id)
    set_email_reply_to(Settings.govuk_notify.zendesk_reply_to_id)

    set_personalisation(
      added_by_name: membership.added_by.name,
      added_by_email: membership.added_by.email,
      group_url:,
      group_name: membership.group.name,
      **role_template_conditions(membership),
    )

    mail(to: membership.user.email)
  end

private

  def role_template_conditions(membership)
    roles = {
      editor: "no",
      group_admin: "no",
    }

    roles[membership.role.to_sym] = "yes"
    roles
  end
end
