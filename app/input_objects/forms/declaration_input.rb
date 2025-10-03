class Forms::DeclarationInput < Forms::MarkCompleteInput
  include TextInputHelper

  attr_accessor :declaration_text

  validates :declaration_text, length: { maximum: 2000 }

  before_validation :strip_carriage_returns_from_input

  def submit
    return false if invalid?

    form.declaration_text = declaration_text
    form.declaration_section_completed = mark_complete
    form.save_draft!
  end

  def assign_form_values
    self.declaration_text = form.declaration_text
    self.mark_complete = form.try(:declaration_section_completed)
    self
  end

private

  def strip_carriage_returns_from_input
    strip_carriage_returns!(declaration_text)
  end
end
