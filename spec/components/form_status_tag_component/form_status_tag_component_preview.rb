class FormStatusTagComponent::FormStatusTagComponentPreview < ViewComponent::Preview
  def default
    render(FormStatusTagComponent::View.new)
  end

  def live_status
    render(FormStatusTagComponent::View.new(status: "live"))
  end

  def archived_status
    render(FormStatusTagComponent::View.new(status: "archived"))
  end
end
