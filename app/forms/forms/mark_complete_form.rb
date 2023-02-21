class Forms::MarkCompleteForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :mark_complete, :form

  validates :mark_complete, presence: true

  def mark_section
    return false if invalid?

    form.question_section_completed = mark_complete
    if form.save!
      true
    else
      false
    end
  end

  def assign_form_values
    self.mark_complete = form.try(:question_section_completed)
    self
  end
end
