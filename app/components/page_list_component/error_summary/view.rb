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

      def error_object(error_name:, condition_id:, page_index:)
        OpenStruct.new(message: I18n.t("page_conditions.errors.error_summary.#{error_name}", page_index:), link: "##{self.class.error_id(condition_id)}")
      end

      def conditions_with_page_indexes
        @pages.map { |page| page.conditions.map { |condition| OpenStruct.new(condition:, page_index: page.position) } }
          .flatten
      end

      def errors_for_summary
        conditions_with_page_indexes
          .map { |condition_with_page_index|
            condition_with_page_index.condition.validation_errors.map do |error|
              error_object(
                error_name: error.name,
                page_index: condition_with_page_index.page_index,
                condition_id: condition_with_page_index.condition.id,
              )
            end
          }
          .flatten
      end
    end
  end
end
