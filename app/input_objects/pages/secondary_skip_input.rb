class Pages::SecondarySkipInput < BaseInput
  attr_accessor :form, :page, :routing_page_id, :goto_page_id, :record

  validates :routing_page_id, :goto_page_id, presence: true
  validate :pages_in_valid_order

  def submit
    return false if invalid?

    ConditionRepository.create!(form_id: form.id,
                                page_id: routing_page_id,
                                check_page_id: page.id,
                                routing_page_id:,
                                answer_value: nil,
                                goto_page_id: skip_to_end? ? nil : goto_page_id,
                                skip_to_end: skip_to_end?)
  end

  def goto_page_options
    [
      *pages_after_current_page(form.pages, page).map { |p| OpenStruct.new(id: p.id, question_text: p.question_with_number) },
      OpenStruct.new(id: "check_your_answers", question_text: I18n.t("page_conditions.check_your_answers")),
    ]
  end

  def routing_page_options
    pages_after_current_page(form.pages, page).map { |p| OpenStruct.new(id: p.id, question_text: p.question_with_number) }
  end

  def page_name(page_id)
    target_page = form.pages.find { |page| page.id == page_id }

    page_name = target_page.question_text
    page_position = target_page.position

    I18n.t("page_route_card.page_name", page_position:, page_name:)
  end

  def end_page_name
    I18n.t("page_route_card.check_your_answers")
  end

  def answer_value
    page.conditions.find { |rc| rc.answer_value.present? }.answer_value
  end

  def continue_to
    page.has_next_page? ? page_name(page.next_page) : end_page_name
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

      routing_page = form.pages.find { |page| page.id.to_s == routing_page_id }
      goto_page = form.pages.find { |page| page.id.to_s == goto_page_id }

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
