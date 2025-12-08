class Forms::CopyInput < Forms::NameInput
  include TextInputHelper

  attr_accessor :copied_name

  validates :copied_name, presence: true, length: { maximum: 2000 }

  def submit
    return false if invalid?

    form.name = copied_name
    form.save_draft!
  end

  def assign_form_values
    self.name = copied_name
    self
  end
end
