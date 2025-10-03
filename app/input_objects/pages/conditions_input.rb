class Pages::ConditionsInput < BaseInput
  attr_accessor :form, :page, :check_page_id, :routing_page_id, :answer_value, :goto_page_id, :record, :skip_to_end

  validates :answer_value, :goto_page_id, presence: true

  def submit
    return false if invalid?

    if create_exit_page?
      true
    else
      assign_skip_to_end

      Condition.create_and_update_form!(
        check_page_id: page.id,
        routing_page_id: page.id,
        answer_value:,
        goto_page_id:,
        skip_to_end:,
      )
    end
  end

  def update_condition
    return false if invalid?

    record.answer_value = answer_value

    unless create_exit_page? || goto_page_id == "exit_page"
      assign_skip_to_end

      record.skip_to_end = skip_to_end
      record.goto_page_id = goto_page_id
      record.exit_page_heading = nil
      record.exit_page_markdown = nil
    end

    record.save_and_update_form
  end

  def routing_answer_options
    options = page.answer_settings.selection_options.map { |option| OpenStruct.new(value: option[:name], label: option[:name]) }
    options << OpenStruct.new(value: :none_of_the_above.to_s, label: I18n.t("page_conditions.none_of_the_above")) if page.is_optional

    options
  end

  def goto_page_options
    page_options = pages_after_position(page.position + 1).map { |p| OpenStruct.new(id: p.id, question_text: p.question_with_number) }
    page_options << OpenStruct.new(id: "check_your_answers", question_text: I18n.t("page_conditions.check_your_answers"))

    page_options
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
    if record.exit_page?
      self.goto_page_id = "exit_page"
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

  def next_page_number
    if page.has_next_page?
      target_page = form.pages.find { it.id == page.next_page }
      target_page.position
    end
  end

  def create_exit_page?
    goto_page_id == "create_exit_page"
  end

  def secondary_skip?
    PageRoutesService.new(form:, pages: form.pages, page:).routes.find(&:secondary_skip?)
  end

private

  def pages_after_position(position)
    all_pages = form.pages
    all_pages.filter { |page| page.position > position }
  end
end
