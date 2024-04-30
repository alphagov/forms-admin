class Forms::MarkCompleteInput < BaseInput
  attr_accessor :mark_complete, :form

  validates :mark_complete, presence: true
  validate :has_routing_errors, if: :marked_complete?

  def submit
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

  def marked_complete?
    mark_complete == "true"
  end

  def has_routing_errors
    errors.add :base, :has_routing_errors if form.has_routing_errors?
  end
end
