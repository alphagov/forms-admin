class User < ApplicationRecord
  include GDS::SSO::User

  serialize :permissions, Array

  enum :role, {
    super_admin: "super_admin",
    editor: "editor",
  }

  module ClassMethods
    def find_for_gds_oauth(auth_hash)
      logger.debug('custom find_for_gds_oauth called')
      user_params = GDS::SSO::User.user_params_from_auth_hash(auth_hash.to_hash)
      user_params["provider"] = :gds
      user = where(provider: user_params["provider"], uid: user_params["uid"]).first ||
        where(email: user_params["email"]).first

      if user
        user.update!(user_params)
        user
      else # Create a new user.
        create!(user_params)
      end
    end
  end
end
