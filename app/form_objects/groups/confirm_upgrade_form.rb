module Groups
  class ConfirmUpgradeForm < ConfirmActionForm
    include Rails.application.routes.url_helpers

    attr_accessor :group, :current_user, :host

    def submit
      group.active!
      send_notification_emails
    end

  private

    def send_notification_emails
      group.memberships.each do |membership|
        send_notification_email(membership.user) if membership.group_admin?
      end
    end

    def send_notification_email(user)
      GroupUpgradedMailer.group_upgraded_email(
        upgraded_by_user: current_user,
        to_email: user.email,
        group:,
        group_url: group_url(group, host:),
      ).deliver_now
    end
  end
end
