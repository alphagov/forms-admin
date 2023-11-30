module GuidanceValidation
  extend ActiveSupport::Concern

  included do
    validate :guidance_fields_presence
    validates :page_heading, length: { maximum: 250 }
    validates :guidance_markdown, markdown: { allow_headings: true }
  end

private

  def guidance_fields_presence
    if page_heading.present? && guidance_markdown.blank?
      errors.add(:guidance_markdown, :blank)
    elsif guidance_markdown.present? && page_heading.blank?
      errors.add(:page_heading, :blank)
    end
  end
end
