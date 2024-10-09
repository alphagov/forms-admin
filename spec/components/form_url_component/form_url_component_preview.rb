class FormUrlComponent::FormUrlComponentPreview < ViewComponent::Preview
  def default
    render(FormUrlComponent::View.new(runner_link: "https://submit.forms.service.gov.uk/example-form"))
  end
end
