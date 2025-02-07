class Pages::DeleteConditionInput < ConfirmActionInput
  attr_accessor :form, :page, :check_page_id, :routing_page_id, :answer_value, :goto_page_id, :record

  def submit
    return false if invalid?

    result = true

    if confirmed?
      result = ConditionRepository.destroy(record)
    end

    result
  end

  def goto_page_question_text
    return I18n.t("page_conditions.check_your_answers") if goto_page_id.nil? && record.skip_to_end

    FormRepository.pages(form).filter { |p| p.id == goto_page_id }.first&.question_text
  end
end
