class Forms::DeleteConfirmationForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :confirm_deletion

  validates :confirm_deletion, presence: true
end
