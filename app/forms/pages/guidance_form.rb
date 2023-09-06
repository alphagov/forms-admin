require "govuk_forms_markdown"

class Pages::GuidanceForm < BaseForm
  include GuidanceValidation

  attr_accessor :page_heading, :guidance_markdown

  def submit(session)
    return false if invalid?

    session[:page] = {} if session[:page].blank?
    session[:page][:page_heading] = page_heading
    session[:page][:guidance_markdown] = guidance_markdown
  end
end
