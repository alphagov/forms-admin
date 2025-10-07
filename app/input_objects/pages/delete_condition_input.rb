class Pages::DeleteConditionInput < ConfirmActionInput
  attr_accessor :form, :page, :record

  delegate :check_page_id, :routing_page_id, :goto_page_id, :answer_value, to: :record

  def submit
    return false if invalid?

    record.destroy_and_update_form! if confirmed?
    true
  end

  def goto_page_question_text
    return I18n.t("page_conditions.check_your_answers") if goto_page_id.nil? && record.skip_to_end

    pages.filter { |p| p.id == goto_page_id }.first&.question_text
  end

  def has_secondary_skip?
    check_page = pages.find(proc { raise "Cannot find page with id #{check_page_id}" }) { it.id == check_page_id }
    page_conditions_service = PageConditionsService.new(form:, pages:, page: check_page)
    page_conditions_service.check_conditions.any? { it != record && it.routing_page_id != it.check_page_id }
  end

private

  def pages
    @pages ||= form.pages
  end
end
