class Pages::AdditionalGuidanceForm < BaseForm
  attr_accessor :page_heading, :additional_guidance_markdown

  validates :page_heading, :additional_guidance_markdown, presence: true
end
