class UserUpgradeRequestService
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def request_upgrade
    UserUpgradeRequestMailer.upgrade_request_email(user_email: user.email).deliver_now
    EventLogger.log({
      event: "upgrade_request",
      user_id: user.id,
    })
  end
end
