class Forms::WelshPageTranslationInput < BaseInput
  include TextInputHelper

  attr_accessor :id, :question_text_cy, :hint_text_cy, :page_heading_cy, :guidance_markdown_cy

  def submit
    return false if invalid?

    page.question_text_cy = question_text_cy
    page.hint_text_cy = hint_text_cy
    page.page_heading_cy = page_heading_cy
    page.guidance_markdown_cy = guidance_markdown_cy

    page.save!
  end

  def assign_page_values
    self.question_text_cy = page.question_text_cy
    self.hint_text_cy = page.hint_text_cy
    self.page_heading_cy = page.page_heading_cy
    self.guidance_markdown_cy = page.guidance_markdown_cy

    self
  end

  def page
    @page ||= Page.find(id)
    @page
  end
end
