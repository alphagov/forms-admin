class FormStateTagComponent::FormStateTagComponentPreview < ViewComponent::Preview
  def default
    render(FormStateTagComponent::View.new)
  end

  def live_status
    render(FormStateTagComponent::View.new(state: "live"))
  end
end
