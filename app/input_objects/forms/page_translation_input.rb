class Forms::PageTranslationInput < BaseInput
  include TextInputHelper

  attr_accessor :id, :question_text_cy, :hint_text_cy, :page_heading_cy, :guidance_markdown_cy

  def submit
    return false if invalid?

    form_page.question_text_cy = question_text_cy
    form_page.hint_text_cy = hint_text_cy
    form_page.page_heading_cy = page_heading_cy
    form_page.guidance_markdown_cy = guidance_markdown_cy

    form_page.save!
  end

  def assign_page_values
    self.question_text_cy = form_page.question_text_cy
    self.hint_text_cy = form_page.hint_text_cy
    self.page_heading_cy = form_page.page_heading_cy
    self.guidance_markdown_cy = form_page.guidance_markdown_cy

    self
  end

  def form_page
    @page ||= Page.find(id)
    @page
  end
end
