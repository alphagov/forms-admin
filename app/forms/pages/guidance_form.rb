require "govuk_forms_markdown"

class Pages::GuidanceForm < BaseForm
  include GuidanceValidation

  attr_accessor :page_heading, :guidance_markdown, :draft_question

  def submit
    return false if invalid?

    draft_question.page_heading = page_heading
    draft_question.guidance_markdown = guidance_markdown
    draft_question.save!(validate: false)
  end
end
