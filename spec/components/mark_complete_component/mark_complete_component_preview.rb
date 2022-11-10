require "factory_bot"
class MarkCompleteComponent::MarkCompleteComponentPreview < ViewComponent::Preview
  def default
    form = FactoryBot.build(:form, id: 1)
    mark_complete_form = Forms::MarkCompleteForm.new(form:).assign_form_values
    render(MarkCompleteComponent::View.new(form_model: mark_complete_form, path: "/", legend: "Have you finished editing your questions?"))
  end

  def excluding_form
    form = FactoryBot.build(:form, id: 1)
    mark_complete_form = Forms::MarkCompleteForm.new(form:).assign_form_values
    form_builder = GOVUKDesignSystemFormBuilder::FormBuilder.new(:form, mark_complete_form,
                                                                 ActionView::Base.new(ActionView::LookupContext.new(nil), {}, nil), {})
    render(MarkCompleteComponent::View.new(form_builder:, generate_form: false))
  end
end
