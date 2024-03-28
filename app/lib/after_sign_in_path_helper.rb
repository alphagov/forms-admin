# class AfterSignInPathHelper
#   include Rails.application.routes.url_helpers

#   attr_reader :user, :default_path

#   def initialize(user, default_path: root_path)
#     @user = user
#     @default_path = default_path
#   end

#   def next_path(user, default_path: root_path)
#     return edit_account_organisation_path if user.organisation.blank?
#     return edit_account_name_path if user.name.blank?

#     default_path
#   end
# end

module AfterSignInPathHelper
  def after_sign_in_next_path
    return edit_account_organisation_path if current_user.organisation.blank?
    return edit_account_name_path if current_user.name.blank?

    stored_location || root_path
  end

  def store_location(path)
    # NOTE: If we ever start using Warden scopes, the key of this session
    # variable should change depending on the scope in warden.options
    session["user_return_to"] = path
  end

  def stored_location
    session["user_return_to"]
  end
end
