class Pages::DeleteSecondarySkipInput < ConfirmActionInput
  attr_accessor :form, :page, :record

  validates :confirm, presence: true

  def submit
    return false if invalid?

    result = true

    if confirmed?

      record.prefix_options[:form_id] = form.id
      record.prefix_options[:page_id] = record.routing_page_id
      result = ConditionRepository.destroy(record)
    end

    result
  end
end
