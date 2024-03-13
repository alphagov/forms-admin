class GroupPolicy < ApplicationPolicy
  def new?
    true
  end
  alias_method :create?, :new?

  def show?
    user.super_admin? || user.groups.include?(record)
  end

  alias_method :edit?, :show?
  alias_method :update?, :edit?
  alias_method :destroy?, :edit?

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.super_admin?
        scope.all
      else
        scope.for_user(user)
      end
    end
  end
end
