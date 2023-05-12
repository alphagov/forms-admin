module PageListComponent
  class View < ViewComponent::Base
    delegate :question_text_with_optional_suffix, to: :helpers

    def initialize(form_id:, can_edit_page_routing:, pages: [])
      super
      @pages = pages
      @form_id = form_id
      @can_edit_page_routing = can_edit_page_routing
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

    def error_link(error_key:, edit_link:, page:, field:)
      content_tag(
        :a,
        I18n.t("page_conditions.errors.page_list.#{error_key}", page_index: page.position),
        class: "govuk-link app-page_list__route-text--error",
        href: "#{edit_link}##{Pages::ConditionsForm.new.id_for_field(field)}",
      )
    end

    def answer_value_text_for_condition(condition, edit_link, page)
      if condition.errors_include?("answer_value_doesnt_exist")
        error_link(error_key: "answer_value_doesnt_exist", edit_link:, page:, field: :answer_value)
      else
        I18n.t("page_conditions.condition_answer_value_text", answer_value: condition.answer_value)
      end
    end

    def goto_page_text_for_condition(condition, edit_link, page)
      if condition.errors_include?("goto_page_doesnt_exist")
        error_link(error_key: "goto_page_doesnt_exist", edit_link:, page:, field: :goto_page_id)
      else
        I18n.t("page_conditions.condition_goto_page_text", goto_page_text: question_text_for_page(condition.goto_page_id))
      end
    end

    def render_routing?
      @can_edit_page_routing
    end
  end
end
