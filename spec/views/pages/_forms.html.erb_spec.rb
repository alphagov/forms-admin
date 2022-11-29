require "rails_helper"

describe "pages/_form.html.erb", type: :view do
  let(:question) { build :page, id: 1, form_id: 1 }
  let(:form) { build :form, id: 1, pages: [question] }
  let(:is_new_page) { true }

  before do

    # This is normally done in the ApplicationController, but we aren't using
    # that in this test
    ActionView::Base.default_form_builder = GOVUKDesignSystemFormBuilder::FormBuilder

    render partial: 'pages/form', locals: { is_new_page: is_new_page,
                                            form_object: form,
                                            page_object: question,
                                            action_path: 'http://example.com',
                                            change_answer_type_path: "http://change-me-please.com"
    }
  end

  describe "new question detail page" do
    it "has a hidden field for the answer type" do
      page = Capybara.string(rendered)
      expect(page.find('#page_answer_type', visible: false)[:value]).to eq question.answer_type
    end
  end

  describe "edit question details page" do
    let(:is_new_page) { false }

    it "has no hidden field for the answer type" do
      page = Capybara.string(rendered)
      expect(page).not_to have_selector('#page_answer_type', visible: false)
    end
  end
end
