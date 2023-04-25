class Pages::ConditionsForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :form, :page, :check_page_id, :routing_page_id, :answer_value, :goto_page_id, :record

  validates :answer_value, :goto_page_id, presence: true

  def submit
    return false if invalid?

    Condition.create!(form_id: form.id,
                      page_id: page.id,
                      check_page_id: page.id,
                      routing_page_id: page.id,
                      answer_value:,
                      goto_page_id:)
  end

  def update
    return false if invalid?

    record.answer_value = answer_value
    record.goto_page_id = goto_page_id

    record.save!
  end

  def routing_answer_options
    options = page.answer_settings.selection_options.map { |option| OpenStruct.new(value: option.name, label: option.name) }
    options << OpenStruct.new(value: I18n.t("page_options_service.selection_type.none_of_the_above"), label: I18n.t("page_options_service.selection_type.none_of_the_above")) if page.is_optional

    [OpenStruct.new(value: nil, label: I18n.t("helpers.label.pages_conditions_form.default_answer_value")), options].flatten
  end

  def goto_page_options
    # TODO: add end of form/check your answers as an option
    [OpenStruct.new(id: nil, question_text: I18n.t("helpers.label.pages_conditions_form.default_goto_page_id")), form.pages.map { |p| OpenStruct.new(id: p.id, question_text: p.question_text) }].flatten
  end
end
