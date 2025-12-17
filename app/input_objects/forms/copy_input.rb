class Forms::CopyInput < Forms::NameInput
  include TextInputHelper

  attr_accessor :tag

  validates :name, length: { maximum: 2000 }
  validates :tag, inclusion: { in: %w[draft live archived] }

  def assign_form_values
    self.name = form.name

    self
  end

  def submit
    return false if invalid?

    form.name = name
    tag
  end
end
