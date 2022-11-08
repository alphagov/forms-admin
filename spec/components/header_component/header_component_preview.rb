class HeaderComponent::HeaderComponentPreview < ViewComponent::Preview
  def default
    render(HeaderComponent::View.new(nil))
  end

  def with_user
    current_user = OpenStruct.new(name: "A User")
    render(HeaderComponent::View.new(current_user))
  end
end
