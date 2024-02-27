class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :group
  belongs_to :added_by, class_name: "User"

  validate :user_and_group_in_same_organisation
  validates :user, uniqueness: { scope: :group }

  def self.destroy_invalid_organisation_memberships(user)
    Membership.joins(:group).where(user:).where.not(groups: { organisation_id: user.organisation_id }).destroy_all
  end

private

  def user_and_group_in_same_organisation
    return if user.nil? || group.nil?
    return if user.organisation == group.organisation

    errors.add :base, "User and group must have the same organisation"
  end
end
