class Pages::AdditionalGuidanceForm < BaseForm
  attr_accessor :page_heading, :guidance_markdown

  validates :page_heading, :guidance_markdown, presence: true

  def submit(session)
    return false if invalid?

    session[:page] = {} if session[:page].blank?
    session[:page][:page_heading] = page_heading
    session[:page][:guidance_markdown] = guidance_markdown
  end
end
