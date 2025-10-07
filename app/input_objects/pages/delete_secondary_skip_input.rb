class Pages::DeleteSecondarySkipInput < ConfirmActionInput
  attr_accessor :form, :page, :record

  validates :confirm, presence: true

  def submit
    return false if invalid?

    record.destroy_and_update_form! if confirmed?
    true
  end
end
