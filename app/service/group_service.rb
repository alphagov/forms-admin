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

  def request_upgrade
    @group.upgrade_requested!
  end

private

  def send_group_upgraded_emails
    @group.memberships.each do |membership|
      send_group_updated_email(membership.user) if notify_member?(membership)
    end
  end

  def notify_member?(membership)
    membership.group_admin? && membership.user.id != @current_user.id
  end

  def send_group_updated_email(user)
    GroupUpgradeMailer.group_upgraded_email(
      upgraded_by_name: @current_user.name,
      to_email: user.email,
      group_name: @group.name,
      group_url: group_url(@group, host: @host),
    ).deliver_now
  end
end
