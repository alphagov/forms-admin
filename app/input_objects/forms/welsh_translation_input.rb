class Forms::WelshTranslationInput < Forms::MarkCompleteInput
  include TextInputHelper

  attr_accessor :pages

  def submit
    return false if invalid?

    pages.each_value do |page|
      form_page = form.pages.find_by(id: page["id"])
      form_page.question_text_cy = page["question_text_cy"]
      form_page.hint_text_cy = page["hint_text_cy"]
      form_page.page_heading_cy = page["page_heading_cy"]
      form_page.guidance_markdown_cy = page["guidance_markdown_cy"]

      form_page.save!
    end

    form.welsh_completed = mark_complete
    form.save_draft!
  end

  def assign_form_values
    self.pages = form.pages
    self.mark_complete = form.try(:welsh_completed)
    self
  end
end
