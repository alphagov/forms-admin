class Forms::CopyInput < Forms::NameInput
  include TextInputHelper

  validates :name, length: { maximum: 2000 }
end
