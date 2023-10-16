class HeaderComponent::HeaderComponentPreview < ViewComponent::Preview
  def default
    render(HeaderComponent::View.new(is_signed_in: false,
                                     list_of_users_path: nil,
                                     user_name: nil,
                                     user_profile_link: nil,
                                     mou_path: nil,
                                     signout_link: nil))
  end

  def with_user_on_production
    render(HeaderComponent::View.new(is_signed_in: true,
                                     list_of_users_path: nil,
                                     user_name: "Joe Smith",
                                     user_profile_link: "http://www.example.com/",
                                     signout_link: "http://www.example.com/",
                                     mou_path: nil,
                                     hosting_environment: OpenStruct.new(friendly_environment_name: "production")))
  end

  def with_user_on_staging
    render(HeaderComponent::View.new(is_signed_in: true,
                                     list_of_users_path: nil,
                                     user_name: "Joe Smith",
                                     user_profile_link: "http://www.example.com/",
                                     signout_link: "http://www.example.com/",
                                     mou_path: nil,
                                     hosting_environment: OpenStruct.new(friendly_environment_name: "staging")))
  end

  def with_user_on_dev
    render(HeaderComponent::View.new(is_signed_in: true,
                                     list_of_users_path: nil,
                                     user_name: "Joe Smith",
                                     user_profile_link: "http://www.example.com/",
                                     signout_link: "http://www.example.com/",
                                     mou_path: nil,
                                     hosting_environment: OpenStruct.new(friendly_environment_name: "development")))
  end

  def with_user_on_user_research
    render(HeaderComponent::View.new(is_signed_in: true,
                                     list_of_users_path: nil,
                                     user_name: "Joe Smith",
                                     user_profile_link: "http://www.example.com/",
                                     signout_link: "http://www.example.com/",
                                     mou_path: nil,
                                     hosting_environment: OpenStruct.new(friendly_environment_name: "user research")))
  end

  def with_user_on_local_machine
    render(HeaderComponent::View.new(is_signed_in: true,
                                     list_of_users_path: nil,
                                     user_name: "Joe Smith",
                                     user_profile_link: "http://www.example.com/",
                                     signout_link: "http://www.example.com/",
                                     mou_path: nil,
                                     hosting_environment: OpenStruct.new(friendly_environment_name: "local")))
  end

  def with_user_logged_in_using_basic_http_auth
    render(HeaderComponent::View.new(is_signed_in: true,
                                     list_of_users_path: "/users",
                                     user_name: "Joe Smith",
                                     user_profile_link: nil,
                                     mou_path: nil,
                                     signout_link: nil))
  end

  def with_user_who_can_manage_users
    render(HeaderComponent::View.new(is_signed_in: true,
                                     list_of_users_path: "/users",
                                     user_name: "Joe Smith",
                                     user_profile_link: nil,
                                     mou_path: nil,
                                     signout_link: nil))
  end

  def with_user_who_can_manage_users_and_mous
    render(HeaderComponent::View.new(is_signed_in: true,
                                     list_of_users_path: "/users",
                                     user_name: "Joe Smith",
                                     user_profile_link: nil,
                                     mou_path: "/mous",
                                     signout_link: nil))
  end
end
