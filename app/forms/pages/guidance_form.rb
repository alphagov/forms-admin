class Pages::GuidanceForm < BaseForm
  attr_accessor :page_heading, :guidance_markdown

  validate :guidance_fields_presence

  def submit(session)
    return false if invalid?

    session[:page] = {} if session[:page].blank?
    session[:page][:page_heading] = page_heading
    session[:page][:guidance_markdown] = guidance_markdown
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
