module AfterSignInPathHelper
  def after_sign_in_next_path
    next_account_path || stored_location || root_path
  end

  def next_account_path
    return edit_account_organisation_path if current_user.organisation.blank?

    return edit_account_name_path if current_user.name.blank?

    edit_account_terms_of_use_path if current_user.terms_agreed_at.blank?
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
