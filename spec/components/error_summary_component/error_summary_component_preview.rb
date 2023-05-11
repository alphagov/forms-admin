class ErrorSummaryComponent::ErrorSummaryComponentPreview < ViewComponent::Preview
  def default
    render(ErrorSummaryComponent::View.new)
  end

  def with_errors
    errors = [OpenStruct.new(message: "You have an error", link: "https://example.gov.uk/error1"), OpenStruct.new(message: "You have another error", link: "https://example.gov.uk/error2")]
    render(ErrorSummaryComponent::View.new(errors:))
  end
end
