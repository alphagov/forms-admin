require "govuk_forms_markdown"

class Pages::GuidanceForm < BaseForm
  attr_accessor :page_heading, :guidance_markdown

  validate :guidance_fields_presence
  validate :markdown_length_and_tags

  def submit(session)
    return false if invalid?

    session[:page] = {} if session[:page].blank?
    session[:page][:page_heading] = page_heading
    session[:page][:guidance_markdown] = guidance_markdown
  end

private

  def markdown_length_and_tags
    return true if guidance_markdown.blank?

    markdown_validation = GovukFormsMarkdown.validate(guidance_markdown)

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
