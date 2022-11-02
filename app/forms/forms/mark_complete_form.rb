class Forms::MarkCompleteForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :mark_complete, :form

  validates :mark_complete, presence: true

  def assign_form_values
    self.mark_complete = form.try(:question_section_completed)
    self
  end
end
