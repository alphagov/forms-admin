class Forms::ChangeNameForm < BaseForm
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
    "form_objects/forms/change_name_form"
  end
end
