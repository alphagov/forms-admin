require "factory_bot"
class MarkCompleteComponent::MarkCompleteComponentPreview < ViewComponent::Preview
  def default
    form = FactoryBot.build(:form, :new_form, id: 1)
    mark_complete_form = Forms::MarkCompleteForm.new(form:).assign_form_values
    render(MarkCompleteComponent::View.new(form: mark_complete_form, path: "/", legend: "Have you finished editing your questions?"))
  end
end
