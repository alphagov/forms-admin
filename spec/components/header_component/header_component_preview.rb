class HeaderComponent::HeaderComponentPreview < ViewComponent::Preview
  def default
    render(HeaderComponent::View.new)
  end

  def with_production
    render(HeaderComponent::View.new(hosting_environment: OpenStruct.new(friendly_environment_name: "Production")))
  end

  def with_staging
    render(HeaderComponent::View.new(hosting_environment: OpenStruct.new(friendly_environment_name: "Staging")))
  end

  def with_dev
    render(HeaderComponent::View.new(hosting_environment: OpenStruct.new(friendly_environment_name: "Development")))
  end

  def with_user_research
    render(HeaderComponent::View.new(hosting_environment: OpenStruct.new(friendly_environment_name: "User research")))
  end

  def with_local_machine
    render(HeaderComponent::View.new(hosting_environment: OpenStruct.new(friendly_environment_name: "Local")))
  end
end
