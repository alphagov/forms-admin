class Forms::DeleteConfirmationForm < BaseForm
  attr_accessor :confirm_deletion

  validates :confirm_deletion, presence: true
end
