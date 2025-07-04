class BaseInput
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  after_validation :set_validation_error_logging_attributes

private

  def set_validation_error_logging_attributes
    CurrentLoggingAttributes.validation_errors = errors.map { |error| "#{error.attribute}: #{error.type}" } if errors.any?
    errors.each do |error|
      AnalyticsService.track_validation_errors(input_object_name: self.class.name, field: error.attribute, error_type: error.type)
    end
  end
end
