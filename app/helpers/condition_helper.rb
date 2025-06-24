# frozen_string_literal: true

module ConditionHelper
  def options_for_condition_goto_page(pages, page, condition)
    options_from_questions_for_select(pages, page, condition) +
      options_for_check_your_answers_for_select(condition)
  end

  def options_from_questions_for_select(pages, page, condition = nil)
    raise "condition should be routing condition for page" if condition && condition.routing_page_id != page.id

    pages = pages_after_position(pages, page.position + 1) if page
    selected = selected_for_condition(condition) if condition

    options_from_collection_for_select pages, :id, :question_text, selected
  end

  def options_for_check_your_answers_for_select(condition = nil)
    selected = selected_for_condition(condition) if condition

    options_for_select [[I18n.t("page_conditions.check_your_answers"), "check_your_answers"]], selected
  end

  def options_for_exit_pages_for_select(condition)
    tag.optgroup(label: I18n.t("page_conditions.exit_page_label")) do
      options_for_select [[condition.exit_page_heading, "exit_page"]], selected_for_condition(condition)
    end
  end

  def selected_for_condition(condition)
    if condition.skip_to_end?
      "check_your_answers"
    elsif condition.exit_page?
      "exit_page"
    else
      condition.goto_page_id
    end
  end

private

  def pages_after_position(pages, position)
    pages.filter { |page| page.position > position }
  end
end
