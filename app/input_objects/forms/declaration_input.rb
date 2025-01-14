class Forms::DeclarationInput < Forms::MarkCompleteInput
  attr_accessor :declaration_text

  validates :declaration_text, length: { maximum: 2000 }

  def submit
    return false if invalid?

    form.declaration_text = declaration_text
    form.declaration_section_completed = mark_complete
    FormRepository.save!(form)
  end

  def assign_form_values
    self.declaration_text = form.declaration_text
    self.mark_complete = form.try(:declaration_section_completed)
    self
  end
end
