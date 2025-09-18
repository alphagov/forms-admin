# frozen_string_literal: true

module UsersHelper
  def user_role_options(roles = User.roles.keys)
    roles.map do |role|
      OpenStruct.new(label: I18n.t("users.roles.#{role}.name"), value: role, description: I18n.t("users.roles.#{role}.description"))
    end
  end

  def user_access_options(access_options = %w[true false])
    access_options.map do |access|
      OpenStruct.new(label: I18n.t("users.has_access.#{access}.name"), value: access, description: I18n.t("users.has_access.#{access}.description"))
    end
  end
end
