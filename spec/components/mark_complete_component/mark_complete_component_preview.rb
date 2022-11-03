require "factory_bot"
class MarkCompleteComponent::MarkCompleteComponentPreview < ViewComponent::Preview
  def without_pages
    form = FactoryBot.build(:form, :new_form, id: 1)
    mark_complete_form = Forms::MarkCompleteForm.new(form:).assign_form_values
    render(MarkCompleteComponent::View.new(form.pages, mark_complete_form, "/"))
  end

  def with_pages
    form = FactoryBot.build(:form, :with_pages, id: 2)
    mark_complete_form = Forms::MarkCompleteForm.new(form:).assign_form_values
    render(MarkCompleteComponent::View.new(form.pages, mark_complete_form, "/"))
  end
end
