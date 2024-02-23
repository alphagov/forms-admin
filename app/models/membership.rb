class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :group
  belongs_to :added_by, class_name: "User"

  validate :user_and_group_in_same_organisation
  validates :user, uniqueness: { scope: :group }

private

  def user_and_group_in_same_organisation
    return if user.nil? || group.nil?
    return if user.organisation == group.organisation

    errors.add :base, "User and group must have the same organisation"
  end
end
