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

    def question_text_for_page(id)
      @pages.find { |page| page.id == id }.question_text
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
        I18n.t("page_conditions.condition_goto_page_text", goto_page_text: question_text_for_page(condition.goto_page_id))
      elsif condition.skip_to_end
        I18n.t("page_conditions.condition_goto_page_text", goto_page_text: I18n.t("page_conditions.check_your_answers"))
      else
        I18n.t("page_conditions.condition_goto_page_text_with_errors")
      end
    end
  end
end
