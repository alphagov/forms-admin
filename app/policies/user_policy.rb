class UserPolicy
  attr_reader :user, :record

  class Scope
    attr_reader :user, :record, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.super_admin?
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
    user&.super_admin?
  end
end
