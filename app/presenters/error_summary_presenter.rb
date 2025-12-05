class ErrorSummaryPresenter
  def initialize(errors)
    @errors = errors
  end

  def formatted_error_messages
    @errors.group_by_attribute.values.map { |errors| format_values(errors) }
  end

private

  def format_values(errors)
    error = errors.first
    return [error.attribute, error.message, error.options[:url]] if error_has_custom_url?(error)

    [error.attribute, error.message]
  end

  def error_has_custom_url?(error)
    error.options && error.options[:url].present?
  end
end
