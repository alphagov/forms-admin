class HeaderComponent::HeaderComponentPreview < ViewComponent::Preview
  def default
    render(HeaderComponent::View.new(is_signed_in: false,
                                     list_of_users_path: nil,
                                     user_name: nil,
                                     user_profile_link: nil,
                                     signout_link: nil))
  end

  def with_user
    render(HeaderComponent::View.new(is_signed_in: true,
                                     list_of_users_path: nil,
                                     user_name: "Joe Smith",
                                     user_profile_link: "http://www.example.com/",
                                     signout_link: "http://www.example.com/"))
  end

  def with_user_logged_in_using_basic_http_auth
    render(HeaderComponent::View.new(is_signed_in: true,
                                     list_of_users_path: "/users",
                                     user_name: "Joe Smith",
                                     user_profile_link: nil,
                                     signout_link: nil))
  end

  def with_user_who_can_manage_users
    render(HeaderComponent::View.new(is_signed_in: true,
                                     list_of_users_path: "/users",
                                     user_name: "Joe Smith",
                                     user_profile_link: nil,
                                     signout_link: nil))
  end
end
