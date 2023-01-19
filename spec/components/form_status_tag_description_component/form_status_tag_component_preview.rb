class FormStatusTagDescriptionComponent::FormStatusTagComponentPreview < ViewComponent::Preview
  def default
    render(FormStatusTagDescriptionComponent::View.new)
  end

  def live_status
    render(FormStatusTagDescriptionComponent::View.new(status: "live"))
  end
end
