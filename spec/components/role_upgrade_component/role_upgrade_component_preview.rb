class RoleUpgradeComponent::RoleUpgradeComponentPreview < ViewComponent::Preview
  def default
    render(RoleUpgradeComponent::View.new)
  end
end
