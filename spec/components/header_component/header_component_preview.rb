class HeaderComponent::HeaderComponentPreview < ViewComponent::Preview
  def default
    render(HeaderComponent::View.new(is_signed_in: false,
                                     user_name: nil,
                                     user_profile_link: nil,
                                     signout_link: nil))
  end

  def with_user
    render(HeaderComponent::View.new(is_signed_in: true,
                                     user_name: "Joe Smith",
                                     user_profile_link: "http://www.example.com/",
                                     signout_link: "http://www.example.com/"))
  end

  def with_user_who_has_no_name
    render(HeaderComponent::View.new(is_signed_in: true,
                                     user_name: nil,
                                     user_profile_link: "http://www.example.com/",
                                     signout_link: "http://www.example.com/"))
  end
end
