require "rails_helper"

describe "pages/edit.html.erb" do
  let(:question_text) { nil }

  let(:form) { build :form, id: 1, pages: [page] }
  let(:page) { build :page, id: 1, question_text:, form_id: 1, answer_type: "email", answer_settings: nil, page_heading: nil }

  let(:draft_question) { question_form.draft_question }
  let(:question_form) do
    build :question_form,
          form_id: form.id,
          answer_type: page.answer_type,
          question_text: page.question_text,
          hint_text: page.hint_text
  end

  let(:current_user) { OpenStruct.new(uid: "123456") }

  before do
    # If models aren't persisted, they won't work with form builders correctly
    without_partial_double_verification do
      allow(form).to receive(:persisted?).and_return(true)
      allow(view).to receive(:address_settings_edit_path).and_return("/address-settings")
      allow(view).to receive(:name_settings_edit_path).and_return("/name-settings")
      allow(view).to receive(:current_form).and_return(form)
      allow(view).to receive(:draft_question).and_return(draft_question)
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

  context "when given a title with characters which need escaping" do
    let(:question_text) { "Question'<> 1" }

    it "has the correct title" do
      expect(view.content_for(:title)).to have_content("Question'<> 1")
    end
  end
end
