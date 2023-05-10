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

  def goto_page_options
    [OpenStruct.new(id: nil, question_text: I18n.t("helpers.label.pages_conditions_form.default_goto_page_id")), form.pages.map { |p| OpenStruct.new(id: p.id, question_text: p.question_text) }].flatten
  end
end
