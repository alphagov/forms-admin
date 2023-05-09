class User < ApplicationRecord
  include GDS::SSO::User

  belongs_to :organisation, optional: true

  serialize :permissions, Array

  enum :role, {
    super_admin: "super_admin",
    editor: "editor",
  }

  validates :role, presence: true

  def user_role_options(roles = User.roles.keys)
    roles.map do |role|
      OpenStruct.new(label: I18n.t("users.roles.#{role}.name"), value: role, description: I18n.t("users.roles.#{role}.description"))
    end
  end
end
