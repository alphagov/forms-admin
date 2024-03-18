class GroupFormPolicy < ApplicationPolicy
  def new?
    record.group && Pundit.policy!(user, record.group).show?
  end
  alias_method :create?, :new?
end
