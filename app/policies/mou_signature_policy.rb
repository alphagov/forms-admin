class MouSignaturePolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def can_manage_mous?
    user.super_admin?
  end
end
