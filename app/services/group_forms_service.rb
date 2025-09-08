class GroupFormsService
  def initialize(group:, form:, current_user:, old_group:)
    @group = group
    @form = form
    @current_user = current_user
    @old_group = old_group
  end

  def move_form_to(new_group)
    GroupForm.transaction do
      group_form = GroupForm.find_by(group: @old_group, form_id: @form.id)
      group_form.update!(group: new_group)
      send_move_emails
    end
  end

private

  def send_move_emails
    @old_group.organisation.admin_users.each do |user|
      next if user.id == @current_user.id

      send_move_email_to_org_admin_user(user.email)
    end

    # TODO: send emails to other group admins/editors
  end

  def send_move_email_to_org_admin_user(to_email)
    GroupFormsMoveMailer.form_moved_email_org_admin(
      to_email: to_email,
      form_name: @form.name,
      old_group_name: @old_group.name,
      new_group_name: @group.name,
      org_admin_email: @current_user.email,
      org_admin_name: @current_user.name,
    ).deliver_now
  end
end
