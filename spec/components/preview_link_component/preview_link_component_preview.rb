class PreviewLinkComponent::PreviewLinkComponentPreview < ViewComponent::Preview
  def without_pages
    render(PreviewLinkComponent::View.new([], "https://submit.forms.service.gov.uk/example-form"))
  end

  def with_pages
    pages = [{ id: 183, question_text: "What is your address?", hint_text: "", answer_type: "address" }]
    render(PreviewLinkComponent::View.new(pages, "https://submit.forms.service.gov.uk/example-form"))
  end

  def with_custom_link_text
    pages = [{ id: 183, question_text: "What is your address?", hint_text: "", answer_type: "address" }]
    render(PreviewLinkComponent::View.new(pages, "https://submit.forms.service.gov.uk/example-form", "A special preview link"))
  end
end
