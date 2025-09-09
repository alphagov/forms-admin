module PageListComponent
  module ErrorSummary
    class View < ApplicationComponent
      def initialize(pages: [])
        super
        @pages = pages
      end

      def self.error_id(number)
        "condition_#{number}"
      end

      def self.generate_error_message(error_name, condition:, page:)
        # TODO: route_number is hardcoded as 1 here because we know there can be only two conditions. It will need to change in future
        route_number = condition.secondary_skip? ? I18n.t("errors.page_conditions.route_number_for_any_other_answer") : 1

        interpolation_variables = { question_number: page.position, route_number: }

        scope = "errors.page_conditions"
        defaults = [:"#{error_name}"]
        defaults.prepend(:"any_other_answer_route.#{error_name}") if condition.secondary_skip?

        I18n.t(defaults.first, default: defaults.drop(1), scope:, **interpolation_variables)
      end

      def error_object(error_name:, condition:, page:)
        OpenStruct.new(
          message: self.class.generate_error_message(error_name, condition:, page:),
          link: "##{self.class.error_id(condition.id)}",
        )
      end

      def errors_for_summary
        @pages.flat_map(&:routing_conditions)
          .map { |condition|
            condition.validation_errors.map do |error|
              error_object(
                error_name: error.name,
                page: condition.check_page,
                condition: condition,
              )
            end
          }
          .flatten
      end
    end
  end
end
