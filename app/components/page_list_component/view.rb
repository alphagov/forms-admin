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

    def error_id(number)
      "condition_#{number}"
    end

    def error_link(error_name, edit_link)
      content_tag(
        :a,
        I18n.t("page_conditions.errors.#{error_name}"),
        class: "govuk-link app-page_list__route-text--error",
        href: edit_link,
      )
    end

    def answer_value_text_for_condition(condition, edit_link)
      if condition.errors_include?("answer_value_doesnt_exist")
        error_link("answer_value_doesnt_exist", edit_link)
      else
        t("page_conditions.condition_answer_value_text", answer_value: condition.answer_value)
      end
    end

    def goto_page_text_for_condition(condition, edit_link)
      if condition.errors_include?("goto_page_doesnt_exist")
        error_key = condition.errors_include?("answer_value_doesnt_exist") ? "goto_page_doesnt_exist_and_nor_does_answer_value" : "goto_page_doesnt_exist"
        error_link(error_key, edit_link)
      else
        t("page_conditions.condition_goto_page_text", goto_page_text: question_text_for_page(condition.goto_page_id))
      end
    end
  end
end
