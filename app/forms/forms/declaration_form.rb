class Forms::DeclarationForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :form, :declaration_text, :mark_complete

  validates :declaration_text, length: { maximum: 2000 }
  validates :mark_complete, presence: true

  def submit
    return false if invalid?

    form.declaration_text = declaration_text
    form.declaration_section_completed = mark_complete
    form.save!
  end

  def assign_form_values
    self.declaration_text = form.declaration_text
    self.mark_complete = form.try(:declaration_section_completed)
    self
  end
end
