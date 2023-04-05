class UserPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def can_manage_user?
    # Phase 1
    user.email.downcase.include?("@digital.cabinet-office.gov.uk")

    # Phase 2
    # user.super_admin?
  end
end
