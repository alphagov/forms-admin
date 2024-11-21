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
        I18n.t("page_conditions.secondary_skip_description", check_page_text: skip_condition_route_page_text(condition), goto_page_text: goto_page_text_for_condition(condition))
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

    def conditions_for_page_with_index(page_id)
      routing_conditions_with_index.fetch(page_id, [])
    end

    def routing_conditions_with_index
      @routing_conditions_with_index ||= process_routing_conditions
    end

    def skip_condition_route_page_text(condition)
      routing_page = @pages.find { |page| page.id == condition.routing_page_id }
      I18n.t("page_conditions.skip_condition_route_page_text", route_page_text: routing_page.question_text, route_page_position: routing_page.position)
    end

    # Create hash of page_id => [condition, index]
    # where index is the index of the condition in the array of conditions for
    # the page referenced by check_page_id
    def process_routing_conditions
      all_form_conditions = @pages.flat_map(&:conditions).compact_blank

      all_form_conditions
        .group_by(&:check_page_id)
        .values
        .flat_map { |conditions|
          conditions.map.with_index(1) do |condition, index|
            [condition.routing_page_id, [condition, index]] # inclde routing_page_id, so we can group by it
          end
        }
        .group_by(&:first)
        .transform_values { |pairs| pairs.map(&:last) } # drop routing_page_id from the value of the hash - it is now the key
    end
  end
end
