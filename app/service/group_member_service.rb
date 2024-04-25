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
    rows.any? { |row| row.actions.any? }
  end

  def rows
    @rows ||= group.memberships.map(&method(:row))
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

    actions << :delete if can_destroy_membership?(membership)
    actions << (membership.editor? ? :make_group_admin : :make_editor) if can_update_membership?(membership)

    actions
  end

  def can_destroy_membership?(membership)
    Pundit.policy(current_user, membership).destroy?
  end

  def can_update_membership?(membership)
    Pundit.policy(current_user, membership).update?
  end
end
