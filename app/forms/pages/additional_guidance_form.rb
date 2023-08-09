class Pages::AdditionalGuidanceForm < BaseForm
  attr_accessor :page_heading, :additional_guidance_markdown

  validates :page_heading, :additional_guidance_markdown, presence: true

  def submit(session)
    return false if invalid?

    session[:page] = {} if session[:page].blank?
    session[:page][:page_heading] = page_heading
    session[:page][:additional_guidance_markdown] = additional_guidance_markdown
  end
end
