module PageListComponent
  class View < ViewComponent::Base
    delegate :question_text_with_optional_suffix, to: :helpers

    def initialize(form_id:, pages: [])
      super
      @pages = pages
      @form_id = form_id
    end

    def show_up_button(index)
      index != 0
    end

    def show_down_button(index)
      index != @pages.length - 1
    end

    def condition_description(condition)
      if condition.secondary_skip?
        I18n.t("page_conditions.secondary_skip_description", check_page_text: condition_check_page_text(condition), goto_page_text: goto_page_text_for_condition(condition))
      else
        I18n.t("page_conditions.condition_description", check_page_text: condition_check_page_text(condition), goto_page_text: goto_page_text_for_condition(condition), answer_value: answer_value_text_for_condition(condition))
      end
    end

    def condition_check_page_text(condition)
      check_page = @pages.find { |page| page.id == condition.check_page_id }
      I18n.t("page_conditions.condition_check_page_text", check_page_text: check_page.question_text)
    end

    def answer_value_text_for_condition(condition)
      if condition.answer_value.present?
        answer_value = condition.answer_value == :none_of_the_above.to_s ? I18n.t("page_conditions.none_of_the_above") : condition.answer_value
        I18n.t("page_conditions.condition_answer_value_text", answer_value:)
      else
        I18n.t("page_conditions.condition_answer_value_text_with_errors")
      end
    end

    def goto_page_text_for_condition(condition)
      if condition.goto_page_id.present?
        goto_page = @pages.find { |page| page.id == condition.goto_page_id }
        I18n.t("page_conditions.condition_goto_page_text", goto_page_position: goto_page.position, goto_page_text: goto_page.question_text)
      elsif condition.skip_to_end
        I18n.t("page_conditions.condition_goto_page_check_your_answers")
      else
        I18n.t("page_conditions.condition_goto_page_text_with_errors")
      end
    end

    def page_position(page)
      page.position
    end

    def condition_page_position(condition)
      check_page = @pages.find { |page| page.id == condition.check_page_id }
      page_position(check_page)
    end
  end
end
