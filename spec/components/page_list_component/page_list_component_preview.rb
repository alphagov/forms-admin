class PageListComponent::PageListComponentPreview < ViewComponent::Preview
  def default
    render(PageListComponent::View.new(pages: [], form_id: 0))
  end

  def with_pages
    pages = [OpenStruct.new(id: 1, question_text: "Enter your name"),
             OpenStruct.new(id: 2, question_text: "What is your pet's phone number?"),
             OpenStruct.new(id: 3, question_text: "How many pets do you own?")]
    render(PageListComponent::View.new(pages:, form_id: 0))
  end
end
