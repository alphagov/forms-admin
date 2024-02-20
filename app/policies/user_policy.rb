class UserPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.super_admin?
        scope
          .all
      end
    end
  end

  def can_manage_user?
    user.super_admin?
  end
end
