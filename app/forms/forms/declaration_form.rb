class Forms::DeclarationForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :form, :declaration_text

  validates :declaration_text, length: { maximum: 2000 }

  def submit
    return false if invalid?

    form.declaration_text = declaration_text
    form.save!
  end

  def assign_form_values
    self.declaration_text = form.declaration_text
    self
  end
end
