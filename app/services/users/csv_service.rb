module Users
  class CsvService
    HEADERS = [
      "Name",
      "Email",
      "Organisation name",
      "Organisation ID",
      "Role",
      "Access",
      "Terms agreed at",
      "First signed in at",
      "Last signed in at",
    ].freeze

    def initialize(users)
      @users = users
    end

    def csv
      CSV.generate do |csv|
        csv << HEADERS

        @users.each do |user|
          csv << user_row(user)
        end
      end
    end

    def user_row(user)
      [
        user.name || I18n.t("users.index.name_blank"),
        user.email,
        user.organisation&.name || I18n.t("users.index.organisation_blank"),
        user.organisation_id,
        I18n.t("users.roles.#{user.role}.name"),
        I18n.t("users.has_access.#{user.has_access}.name"),
        user.terms_agreed_at,
        user.created_at,
        user.last_signed_in_at,
      ]
    end
  end
end
