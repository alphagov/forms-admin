require "govuk_forms_markdown"

class Pages::GuidanceForm < BaseForm
  include GuidanceValidation

  attr_accessor :page_heading, :guidance_markdown, :draft_question

  validates :draft_question, presence: true

  def submit(session)
    return false if invalid?

    draft_question
      .assign_attributes({ page_heading:, guidance_markdown: })

    draft_question.save!(validate: false)

    # TODO: remove this once we have draft_questions being saved across the whole journey
    session[:page] = {} if session[:page].blank?
    session[:page][:page_heading] = page_heading
    session[:page][:guidance_markdown] = guidance_markdown
  end
end
