class Pages::ConditionsForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :form, :page, :check_page_id, :routing_page_id, :answer_value, :goto_page_id, :record, :skip_to_end

  validates :answer_value, :goto_page_id, presence: true

  def submit
    return false if invalid?

    assign_skip_to_end

    Condition.create!(form_id: form.id,
                      page_id: page.id,
                      check_page_id: page.id,
                      routing_page_id: page.id,
                      answer_value:,
                      goto_page_id:,
                      skip_to_end:)
  end

  def update_condition
    return false if invalid?

    assign_skip_to_end

    record.answer_value = answer_value
    record.goto_page_id = goto_page_id
    record.skip_to_end = skip_to_end

    record.save!
  end

  def routing_answer_options
    options = page.answer_settings.selection_options.map { |option| OpenStruct.new(value: option.name, label: option.name) }
    options << OpenStruct.new(value: I18n.t("page_options_service.selection_type.none_of_the_above"), label: I18n.t("page_options_service.selection_type.none_of_the_above")) if page.is_optional

    [OpenStruct.new(value: nil, label: I18n.t("helpers.label.pages_conditions_form.default_answer_value")), options].flatten
  end

  def goto_page_options
    [OpenStruct.new(id: nil, question_text: I18n.t("helpers.label.pages_conditions_form.default_goto_page_id")), form.pages.map { |p| OpenStruct.new(id: p.id, question_text: p.question_with_number) }, OpenStruct.new(id: "check_your_answers", question_text: I18n.t("page_conditions.check_your_answers"))].flatten
  end

  def check_errors_from_api
    record.errors_with_fields.each do |error|
      errors.add(error[:field], error[:name].to_sym)
    end
  end

  def assign_condition_values
    if goto_page_id.nil? && skip_to_end
      self.goto_page_id = "check_your_answers"
    end
    self
  end

  def assign_skip_to_end
    if goto_page_id == "check_your_answers"
      self.goto_page_id = nil
      self.skip_to_end = true
    else
      self.skip_to_end = false
    end
  end
end
