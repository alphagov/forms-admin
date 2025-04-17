class BaseInput
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  after_validation :set_validation_error_logging_attributes

private

  def set_validation_error_logging_attributes
    CurrentLoggingAttributes.validation_errors = errors.map { |error| "#{error.attribute}: #{error.type}" } if errors.any?
  end
end
