class GroupPolicy < ApplicationPolicy
  def new?
    true
  end
  alias_method :create?, :new?

  def show?
    user.super_admin? || user.is_organisations_admin?(record.organisation) || user.groups.include?(record)
  end
  alias_method :edit?, :show?
  alias_method :update?, :show?

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.super_admin?
        scope.all
      elsif user.organisation_admin?
        scope.for_organisation(user.organisation)
      else
        scope.for_user(user)
      end
    end
  end
end
