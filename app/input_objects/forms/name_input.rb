class Forms::NameInput < BaseInput
  attr_accessor :form, :name

  validates :name, presence: true

  def submit
    return false if invalid?

    form.name = name
    form.save!
  end

  def assign_form_values
    self.name = form.name
    self
  end

  def to_partial_path
    "input_objects/forms/name_input"
  end
end
