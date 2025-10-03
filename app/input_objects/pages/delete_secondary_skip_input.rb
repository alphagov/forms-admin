class Pages::DeleteSecondarySkipInput < ConfirmActionInput
  attr_accessor :form, :page, :record

  validates :confirm, presence: true

  def submit
    return false if invalid?

    result = true

    if confirmed?
      result = record.destroy
    end

    result
  end
end
