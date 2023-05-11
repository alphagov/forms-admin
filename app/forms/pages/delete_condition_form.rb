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
    form.pages.filter { |p| p.id == goto_page_id }.first&.question_text
  end
end
