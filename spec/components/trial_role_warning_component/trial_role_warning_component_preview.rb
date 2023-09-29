class TrialRoleWarningComponent::TrialRoleWarningComponentPreview < ViewComponent::Preview
  def default
    render(TrialRoleWarningComponent::View.new(link_url: "#"))
  end
end
