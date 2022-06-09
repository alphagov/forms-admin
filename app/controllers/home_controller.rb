class HomeController < ApplicationController
  def index
    @forms = Form.all
    @forms.first.pages
    # page = Page.new(form_id: @forms.first.id)
    # page.question_text = "a"
    # page.answer_type = "single_line"
    # page
    # page.save(form_id: @forms.first.id)
  end
end
