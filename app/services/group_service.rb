class GroupService
  include Rails.application.routes.url_helpers

  def initialize(group:, current_user:, host: nil)
    @group = group
    @current_user = current_user
    @host = host
  end

  def upgrade_group
    @group.active!
    send_group_upgraded_emails
  end

  def reject_upgrade
    @group.trial!
    send_upgrade_rejected_emails
  end

  def request_upgrade
    @group.upgrade_requester = @current_user
    @group.upgrade_requested!
    send_group_upgrade_requested_emails
  end

private

  def send_group_upgraded_emails
    @group.memberships.each do |membership|
      send_group_upgraded_email(membership.user.email) if notify_member?(membership)
    end
  end

  def send_upgrade_rejected_emails
    @group.memberships.each do |membership|
      send_upgrade_rejected_email(membership.user.email) if notify_member?(membership)
    end
  end

  def send_group_upgrade_requested_emails
    @group.organisation.admin_users.each do |user|
      send_group_upgrade_requested_email(user.email)
    end
  end

  def notify_member?(membership)
    membership.group_admin? && membership.user.id != @current_user.id
  end

  def send_group_upgraded_email(to_email)
    GroupUpgradeMailer.upgraded_email(
      to_email:,
      upgraded_by_name: @current_user.name,
      group_name: @group.name,
      group_url: group_url(@group, host: @host),
    ).deliver_now
  end

  def send_upgrade_rejected_email(to_email)
    GroupUpgradeMailer.rejected_email(
      to_email:,
      rejected_by_name: @current_user.name,
      rejected_by_email: @current_user.email,
      group_name: @group.name,
      group_url: group_url(@group, host: @host),
    ).deliver_now
  end

  def send_group_upgrade_requested_email(to_email)
    GroupUpgradeMailer.requested_email(
      to_email:,
      requester_name: @current_user.name,
      requester_email_address: @current_user.email,
      group_name: @group.name,
      view_request_url: group_url(@group, host: @host),
    ).deliver_now
  end
end
