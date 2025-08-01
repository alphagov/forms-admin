class Pages::SecondarySkipInput < BaseInput
  attr_accessor :form, :page, :routing_page_id, :goto_page_id, :record

  validates :routing_page_id, :goto_page_id, presence: true
  validate :pages_in_valid_order

  def submit
    return false if invalid?

    # We need to take extra care when updating an exisitng Condition.
    # Because conditions are accessed from the API with page id, we can only
    # update a condition if the user hasn't changed the routing_page_id.
    #
    # If the user has changed the routing_page_id, we need to remove the old
    # Condition and create a new one
    if record.present? && record.routing_page_id.to_s == routing_page_id
      record.routing_page_id = routing_page_id
      record.goto_page_id = skip_to_end? ? nil : goto_page_id
      record.skip_to_end = skip_to_end?

      return ConditionRepository.save!(record)
    end

    if record.present?
      ConditionRepository.destroy(record)
    end

    ConditionRepository.create!(
      form_id: form.id,
      page_id: routing_page_id,
      check_page_id: page.id,
      routing_page_id:,
      answer_value: nil,
      goto_page_id: skip_to_end? ? nil : goto_page_id,
      skip_to_end: skip_to_end?,
    )
  end

  def goto_page_options
    [
      *pages_after_current_page(FormRepository.pages(form), page).map { |p| OpenStruct.new(id: p.id, question_text: p.question_with_number) },
      OpenStruct.new(id: "check_your_answers", question_text: I18n.t("page_conditions.check_your_answers")),
    ]
  end

  def routing_page_options
    pages_after_current_page(FormRepository.pages(form), page).map { |p| OpenStruct.new(id: p.id, question_text: p.question_with_number) }
  end

  def end_page_name
    I18n.t("page_route_card.check_your_answers")
  end

  def answer_value
    page.routing_conditions.find { |rc| rc.answer_value.present? }.answer_value
  end

  def primary_route_goto_page_name
    primary_route = page.routing_conditions.find { |rc| rc.answer_value.present? }

    if primary_route.skip_to_end?
      return I18n.t("page_route_card.check_your_answers")
    end

    question_name(primary_route.goto_page_id) || I18n.t("page_route_card.goto_page_invalid")
  end

  def question_name(page_id)
    target_page = FormRepository.pages(form).find { |page| page.id == page_id }

    return if target_page.blank?

    question_text = target_page.question_text
    question_number = target_page.position

    I18n.t("page_route_card.question_name_long", question_number:, question_text:)
  end

  def next_page_number
    if page.has_next_page?
      target_page = FormRepository.pages(form).find { it.id == page.next_page }
      question_number = target_page.position
      return question_number
    end

    end_page_name
  end

  def assign_values
    self.routing_page_id = record.routing_page_id
    self.goto_page_id = record.goto_page_id.nil? ? "check_your_answers" : record.goto_page_id
    self
  end

private

  def pages_after_current_page(all_pages, current_page)
    all_pages.filter { |page| page.position > current_page.position }
  end

  def skip_to_end?
    goto_page_id == "check_your_answers"
  end

  def goto_question_page?
    !skip_to_end?
  end

  def pages_in_valid_order
    if routing_page_id.present? && goto_page_id.present?

      routing_page = FormRepository.pages(form).find { |page| page.id.to_s == routing_page_id.to_s }
      goto_page = FormRepository.pages(form).find { |page| page.id.to_s == goto_page_id.to_s }

      if goto_page_id == routing_page_id
        errors.add(:goto_page_id, :equal, message: I18n.t("activemodel.errors.models.pages/secondary_skip_input.attributes.goto_page_id.equal"))
      end

      if goto_question_page?
        if routing_page.position > goto_page.position
          errors.add(:goto_page_id, :routing_page_after, message: I18n.t("activemodel.errors.models.pages/secondary_skip_input.attributes.goto_page_id.routing_page_after"))
        end

        if routing_page.position + 1 == goto_page.position
          errors.add(:goto_page_id, :already_consecutive, message: I18n.t("activemodel.errors.models.pages/secondary_skip_input.attributes.goto_page_id.already_consecutive"))
        end
      end
    end
  end
end
