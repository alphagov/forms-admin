require "rails_helper"

describe "pages/edit.html.erb" do
  let(:question_text) { nil }

  before do
    # Initialize models
    page = Page.new(id: 1, question_text:, form_id: 1, answer_type: "email", answer_settings: nil, page_heading: "Some detailed guidance", guidance_markdown: "This is example of detailed guidance")
    question_form = Pages::QuestionForm.new(page_id: 1, question_text:, form_id: 1, answer_type: "email", answer_settings: nil)
    form = Form.new(id: 1, name: "Form 1", form_id: 1, pages: [page])
    current_user = OpenStruct.new(uid: "123456")

    # If models aren't persisted, they won't work with form builders correctly

    without_partial_double_verification do
      allow(question_form).to receive(:persisted?).and_return(true)
      allow(form).to receive(:persisted?).and_return(true)
      allow(view).to receive(:type_of_answer_edit_path).and_return("/type-of-answer")
      allow(view).to receive(:selections_settings_edit_path).and_return("/selections_settings")
      allow(view).to receive(:text_settings_edit_path).and_return("/text-settings")
      allow(view).to receive(:date_settings_edit_path).and_return("/date-settings")
      allow(view).to receive(:address_settings_edit_path).and_return("/address-settings")
      allow(view).to receive(:name_settings_edit_path).and_return("/name-settings")
      allow(view).to receive(:current_form).and_return(form)
    end

    # Assign instance variables so they can be accessed from views
    assign(:page, page)
    assign(:question_form, question_form)
    assign(:current_user, current_user)
    assign(:answer_types, [])

    # This is normally done in the ApplicationController, but we aren't using
    # that in this test
    ActionView::Base.default_form_builder = GOVUKDesignSystemFormBuilder::FormBuilder

    render template: "pages/edit"
  end

  it "contains existing detailed Guidance" do
    expect(rendered).to have_text("Some detailed guidance")
  end

  context "when given a title with characters which need escaping" do
    let(:question_text) { "Question'<> 1" }

    it "has the correct title" do
      expect(view.content_for(:title)).to have_content("Question'<> 1")
    end
  end
end
