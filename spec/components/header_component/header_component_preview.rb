class HeaderComponent::HeaderComponentPreview < ViewComponent::Preview
  def default
    render(HeaderComponent::View.new(nil))
  end

  def with_user
    user_information = OpenStruct.new(name: "A User")
    render(HeaderComponent::View.new(user_information))
  end
end
