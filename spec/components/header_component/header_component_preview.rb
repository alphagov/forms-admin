class HeaderComponent::HeaderComponentPreview < ViewComponent::Preview
  def default
    render(HeaderComponent::View.new)
  end

  def with_production
    render(HeaderComponent::View.new(hosting_environment: OpenStruct.new(friendly_environment_name: "production")))
  end

  def with_staging
    render(HeaderComponent::View.new(hosting_environment: OpenStruct.new(friendly_environment_name: "staging")))
  end

  def with_dev
    render(HeaderComponent::View.new(hosting_environment: OpenStruct.new(friendly_environment_name: "development")))
  end

  def with_user_research
    render(HeaderComponent::View.new(hosting_environment: OpenStruct.new(friendly_environment_name: "user research")))
  end

  def with_local_machine
    render(HeaderComponent::View.new(hosting_environment: OpenStruct.new(friendly_environment_name: "local")))
  end

  def with_navigation_links
    render(HeaderComponent::View.new(navigation_items: [
      { text: "Mous", href: "/mous" },
      { text: "Users", href: "/users" },
      { text: "Joe Smith", href: "/profile" },
      { text: "Sign out", href: "/signout" },
    ]))
  end
end
