class Pages::DeleteConditionForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :form, :page, :check_page_id, :routing_page_id, :answer_value, :goto_page_id, :record, :confirm_deletion

  validates :confirm_deletion, presence: true, inclusion: { in: %w[true false] }

  def delete
    return false if invalid?

    result = true

    if confirm_deletion == "true"
      result = record.destroy
    end

    result
  end

  def goto_page_question_text
    return I18n.t("page_conditions.check_your_answers") if goto_page_id.nil? && record.skip_to_end

    form.pages.filter { |p| p.id == goto_page_id }.first&.question_text
  end
end
