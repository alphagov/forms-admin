class MarkdownValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return true if value.blank?

    markdown_validation = GovukFormsMarkdown.validate(value, allow_headings: options.fetch(:allow_headings))

    return true if markdown_validation[:errors].empty?

    tag_errors = markdown_validation[:errors].excluding(:too_long)

    if tag_errors.any?
      record.errors.add(attribute, :unsupported_markdown_syntax)
    elsif markdown_validation[:errors].include?(:too_long)
      record.errors.add(attribute, :too_long)
    end
  end
end
