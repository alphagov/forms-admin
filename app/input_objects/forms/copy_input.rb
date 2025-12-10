class Forms::CopyInput < Forms::NameInput
  include TextInputHelper

  validates :name, length: { maximum: 2000 }

  def submit
    return false if invalid?

    form.name = name
  end
end
