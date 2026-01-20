class BaseInput
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  after_validation :set_validation_error_logging_attributes

private

  def set_validation_error_logging_attributes
    # Include all errors for splunk, as this will override previous attempts to set CurrentLoggingAttributes.validation_errors
    CurrentLoggingAttributes.validation_errors = errors.map { |error| "#{error.attribute}: #{error.type}" } if errors.any?

    # Remove nested errors in analytics, since they'll already be logged in the object where they were originally raised
    errors_without_nested_errors = errors.reject { |error| error.is_a? ActiveModel::NestedError }

    errors_without_nested_errors.each do |error|
      AnalyticsService.track_validation_errors(input_object_name: self.class.name, field: error.attribute, error_type: error.type, form_name:)
    end
  end

  def form_name
    return form.name if defined?(form) && form.present?
    return draft_question.form_name if defined?(draft_question) && draft_question.present?
    return page.form.name if defined?(page) && page.present?

    nil
  end
end
