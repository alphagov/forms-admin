class ServiceNavigationComponent::ServiceNavigationComponentPreview < ViewComponent::Preview
  def default
    render(ServiceNavigationComponent::View.new)
  end
end
