class Pages::ConditionsForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :form, :page, :check_page_id, :routing_page_id, :answer_value, :goto_page_id

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

  def routing_answer_options
    options = page.answer_settings.selection_options
    options << OpenStruct.new(name: I18n.t("page_options_service.selection_type.none_of_the_above")) if page.is_optional

    [OpenStruct.new(name: nil), options].flatten
  end

  def goto_page_options
    # TODO: add end of form/check your answers as an option
    [OpenStruct.new(id: nil, question_text: nil), form.pages.map { |p| OpenStruct.new(id: p.id, question_text: p.question_text) }].flatten
  end
end
