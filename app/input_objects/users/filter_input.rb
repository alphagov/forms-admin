module Users
  class FilterInput < BaseInput
    include UsersHelper

    ALL_ORGANISATIONS_VALUE = "all".freeze

    attr_accessor :email, :name, :organisation_id, :role, :has_access

    def has_filters?
      [email, name, organisation_id, role, has_access].any?(&:present?)
    end

    def organisation_options
      Organisation.with_users.order(:name).to_a
                  .unshift(OpenStruct.new(name_with_abbreviation: "All organisations", id: ALL_ORGANISATIONS_VALUE))
    end

    def access_options
      user_access_options.unshift(OpenStruct.new(label: I18n.t("users.has_access.any")))
    end

    def role_options
      user_role_options.unshift(OpenStruct.new(label: I18n.t("users.roles.all")))
    end
  end
end
