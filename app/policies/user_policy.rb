class UserPolicy
  attr_reader :user, :record

  class Scope
    attr_reader :user, :record, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.email.downcase.include?("@digital.cabinet-office.gov.uk")
        scope
          .all
      end
    end
  end

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
