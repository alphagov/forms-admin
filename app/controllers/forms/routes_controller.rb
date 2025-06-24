module Forms
  class RoutesController < ApplicationController
    def edit
      pages = FormRepository.pages(current_form)
      routes = get_routes(pages)

      render locals: { current_form:, pages:, routes: }
    end

    def update
      pages = FormRepository.pages(current_form)
      existing_routes = get_routes(pages)
      routes = existing_routes.deep_dup

      # leave updating to the end, in case we have a bug
      conditions_to_update = []
      conditions_to_delete = []

      routes_params.each do |page_id, answers|
        page_id = page_id.to_i

        answers.each do |answer, goto|
          answer_value = answer == "nil" ? nil : answer
          existing_condition = existing_routes.dig(page_id, answer_value)
          existing_goto = existing_condition ? helpers.selected_for_condition(existing_condition).to_s : ""
          next if existing_goto == goto

          condition = if existing_condition
                        # workarounds
                        existing_condition.prefix_options[:form_id] = current_form.id
                        existing_condition.prefix_options[:page_id] = existing_condition.routing_page_id

                        existing_condition
                      else
                        new_condition(page_id, answer)
                      end

          if goto == ""
            conditions_to_delete << condition
            routes[page_id].delete(answer)
            next
          elsif goto == "check_your_answers"
            condition.goto_page_id = nil
            condition.skip_to_end = true
          else
            condition.goto_page_id = goto.to_i
            condition.skip_to_end = false
          end

          condition.exit_page_heading = nil
          condition.exit_page_markdown = nil

          conditions_to_update << condition

          routes[page_id] ||= {}
          routes[page_id][answer] ||= condition
        end
      end

      conditions_to_update.each(&:save!)

      conditions_to_delete.each do |condition|
        ConditionRepository.destroy(condition)
      end

      redirect_to form_pages_path
    end

  private

    def routes_params
      params.expect(routes: {})
    end

    def get_routes(pages)
      form_conditions = pages.flat_map(&:routing_conditions).compact_blank

      form_conditions
        .group_by(&:routing_page_id)
        .transform_values { |conditions| conditions.group_by(&:answer_value).transform_values(&:sole) }
    end

    def new_condition(page_id, answer)
      if answer == "nil"
        answer_value = nil
        check_page_id = nil # we would like to make this a secondary skip by guessing the precondition, but how?
      else
        answer_value = answer
        check_page_id = page_id
      end

      Api::V1::ConditionResource.new(
        form_id: current_form.id,
        page_id: page_id,
        check_page_id:,
        routing_page_id: page_id,
        answer_value:,
      )
    end
  end
end
