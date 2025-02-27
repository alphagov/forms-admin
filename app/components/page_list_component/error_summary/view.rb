module PageListComponent
  module ErrorSummary
    class View < ViewComponent::Base
      def initialize(pages: [])
        super
        @pages = pages
      end

      def self.error_id(number)
        "condition_#{number}"
      end

      def error_object(error_name:, condition:, page:)
        OpenStruct.new(message: I18n.t("page_conditions.errors.#{error_name}", question_number: page.position), link: "##{self.class.error_id(condition.id)}")
      end

      def conditions_with_check_pages
        @pages.map { |page|
          page.routing_conditions.map do |condition|
            check_page = @pages.find { it.id == condition.check_page_id }
            OpenStruct.new(condition:, check_page:)
          end
        }.flatten
      end

      def errors_for_summary
        conditions_with_check_pages
          .map { |condition_with_check_page|
            condition_with_check_page.condition.validation_errors.map do |error|
              error_object(
                error_name: error.name,
                page: condition_with_check_page.check_page,
                condition: condition_with_check_page.condition,
              )
            end
          }
          .flatten
      end
    end
  end
end
