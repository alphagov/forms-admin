module GuidanceValidation
  extend ActiveSupport::Concern

  included do
    validate :guidance_fields_presence
    validates :page_heading, length: { maximum: 250 }
    validate :markdown_length_and_tags
  end

private

  def markdown_length_and_tags
    return true if guidance_markdown.blank?

    markdown_validation = GovukFormsMarkdown.validate(guidance_markdown, allow_headings: true)

    return true if markdown_validation[:errors].empty?

    tag_errors = markdown_validation[:errors].excluding(:too_long)

    if tag_errors.any?
      errors.add(:guidance_markdown, :unsupported_markdown_syntax)
    elsif markdown_validation[:errors].include?(:too_long)
      errors.add(:guidance_markdown, :too_long)
    end
  end

  def guidance_fields_presence
    if page_heading.present? && guidance_markdown.blank?
      errors.add(:guidance_markdown, :blank)
    elsif guidance_markdown.present? && page_heading.blank?
      errors.add(:page_heading, :blank)
    end
  end
end
