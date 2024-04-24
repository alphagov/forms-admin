class GroupMemberService
  Row = Struct.new(:name, :email, :role, :actions, :membership)

  attr_reader :group, :current_user

  class << self
    def call(**args)
      new(**args)
    end
  end

  def initialize(group:, current_user:)
    @group = group
    @current_user = current_user
  end

  def show_actions?
    current_user.super_admin? || current_user.is_organisations_admin?(group.organisation) || current_user.is_group_admin?(group)
  end

  def rows
    group.memberships.map(&method(:row))
  end

private

  def row(membership)
    Row.new(
      name: membership.user.name,
      email: membership.user.email,
      role: membership.role,
      actions: actions(membership),
      membership:,
    )
  end

  def actions(membership)
    actions = []

    if Pundit.policy(current_user, membership).destroy?
      actions << :delete
    end

    actions
  end
end
