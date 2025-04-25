class ServiceNavigationComponent::ServiceNavigationComponentPreview < ViewComponent::Preview
  def default
    render(ServiceNavigationComponent::View.new)
  end

  def with_navigation_links
    render(ServiceNavigationComponent::View.new(navigation_items: [
      { text: "Support", href: "/support" },
      { text: "A User", href: nil },
      { text: "Sign out", href: "/sign-out" },
    ]))
  end

  def with_super_admin_navigation_links
    render(ServiceNavigationComponent::View.new(navigation_items: [
      { text: "MOUs", href: "/mous" },
      { text: "Users", href: "/users" },
      { text: "Reports", href: "/reports" },
      { text: "Support", href: "/support" },
      { text: "A User", href: nil },
      { text: "Sign out", href: "/sign-out" },
    ]))
  end
end
