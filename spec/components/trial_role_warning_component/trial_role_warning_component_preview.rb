class TrialRoleWarningComponent::TrialRoleWarningComponentPreview < ViewComponent::Preview
  def default
    render(TrialRoleWarningComponent::View.new(User.new))
  end
end
