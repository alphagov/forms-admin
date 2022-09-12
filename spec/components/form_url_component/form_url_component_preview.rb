class FormUrlComponent::FormUrlComponentPreview < ViewComponent::Preview
  def default
    render(FormUrlComponent::View.new("https://submit.forms.service.gov.uk/example-form"))
  end
end
