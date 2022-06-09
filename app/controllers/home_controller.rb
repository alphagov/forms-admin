class HomeController < ApplicationController
  def index
    @forms = Form.all
    @forms.first.pages
    # Create a page
    # page = Page.new(form_id: @forms.first.id)
    # page.question_text = "a"
    # page.answer_type = "single_line"
    # page
    # page.save(form_id: @forms.first.id)
    # Find a page
    # page = Page.find(1, params: {form_id: 1})
  end
end
