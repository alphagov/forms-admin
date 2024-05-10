class MembershipPolicy < ApplicationPolicy
  def destroy?
    user.super_admin? || organisation_admin? || (group_admin? && record.editor?)
  end

  def update?
    user.super_admin? || organisation_admin?
  end

private

  def group_admin?
    user.is_group_admin?(record.group)
  end

  def organisation_admin?
    user.is_organisations_admin?(organisation)
  end

  def organisation
    record.group.organisation
  end
end
