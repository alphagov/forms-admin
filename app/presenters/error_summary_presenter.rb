class ErrorSummaryPresenter
  def initialize(errors)
    @errors = errors
  end

  def formatted_error_messages
    first_errors = @errors.group_by_attribute.transform_values do |errors|
      error = errors.first
      [error.attribute, error.message, (error.options && error.options[:url].present? ? error.options[:url] : nil)]
    end

    first_errors.values
  end
end
