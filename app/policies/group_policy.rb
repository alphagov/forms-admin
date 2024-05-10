class GroupPolicy < ApplicationPolicy
  def new?
    true
  end
  alias_method :create?, :new?

  def show?
    user.super_admin? || user.is_organisations_admin?(record.organisation) || user.groups.include?(record)
  end

  def edit?
    user.super_admin? || user.is_organisations_admin?(record.organisation) || group_admin?
  end

  alias_method :update?, :edit?
  alias_method :add_editor?, :edit?

  def upgrade?
    user.super_admin? || user.is_organisations_admin?(record.organisation)
  end

  def request_upgrade?
    group_admin? && !record.active?
  end

private

  def group_admin?
    record.memberships.find_by(user:)&.group_admin?
  end

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
