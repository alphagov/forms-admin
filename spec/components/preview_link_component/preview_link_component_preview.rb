class PreviewLinkComponent::PreviewLinkComponentPreview < ViewComponent::Preview
  def without_pages
    render(PreviewLinkComponent::View.new([], "https://submit.forms.service.gov.uk/example-form"))
  end

  def with_pages
    pages = [{ id: 183, question_text: "What is your address?", hint_text: "", answer_type: "address", next_page: nil }]
    render(PreviewLinkComponent::View.new(pages, "https://submit.forms.service.gov.uk/example-form"))
  end
end
