class HeaderComponent::HeaderComponentPreview < ViewComponent::Preview
  def default
    render(HeaderComponent::View.new(nil))
  end

  def with_user
    current_user = OpenStruct.new(name: "A User", uid: "123456")
    render(HeaderComponent::View.new(current_user))
  end
end
