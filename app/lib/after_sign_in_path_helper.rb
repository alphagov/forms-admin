class AfterSignInPathHelper
  include Rails.application.routes.url_helpers

  attr_reader :user, :default_path

  def initialize(user, default_path: root_path)
    @user = user
    @default_path = default_path
  end

  def next_path
    return edit_account_organisation_path if user.organisation.blank?
    return edit_account_name_path if user.name.blank?

    default_path
  end
end
