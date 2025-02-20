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
        OpenStruct.new(message: I18n.t("page_conditions.errors.#{error_name}", page_index: page.position), link: "##{self.class.error_id(condition.id)}")
      end

      def conditions_with_routing_pages
        @pages.map { |page| page.routing_conditions.map { |condition| OpenStruct.new(condition:, routing_page: page) } }
          .flatten
      end

      def errors_for_summary
        conditions_with_routing_pages
          .map { |condition_with_routing_page|
            condition_with_routing_page.condition.validation_errors.map do |error|
              error_object(
                error_name: error.name,
                page: condition_with_routing_page.routing_page,
                condition: condition_with_routing_page.condition,
              )
            end
          }
          .flatten
      end
    end
  end
end
