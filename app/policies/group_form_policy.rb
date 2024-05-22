class GroupFormPolicy < ApplicationPolicy
  def new?
    Pundit.policy!(user, record.group).show?
  end
  alias_method :create?, :new?
end
