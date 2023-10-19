class MouSignaturePolicy
  attr_reader :user

  def initialize(user, _record)
    @user = user
  end

  def can_manage_mous?
    user.super_admin?
  end
end
