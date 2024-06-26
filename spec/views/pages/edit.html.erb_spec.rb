require "rails_helper"

describe "pages/edit.html.erb" do
  let(:question_text) { nil }

  let(:form) { build :form, id: 1, pages: [page] }
  let(:page) { build :page, id: 1, question_text:, form_id: 1, answer_type:, answer_settings: nil, page_heading: nil }
  let(:answer_type) { "email" }

  let(:draft_question) { question_input.draft_question }
  let(:question_input) do
    build :question_input,
          answer_type: page.answer_type,
          question_text: page.question_text,
          hint_text: page.hint_text
  end

  let(:current_user) { OpenStruct.new(uid: "123456") }

  before do
    # If models aren't persisted, they won't work with form builders correctly
    without_partial_double_verification do
      allow(form).to receive(:persisted?).and_return(true)
      allow(view).to receive_messages(current_form: form, draft_question:)
    end

    # Assign instance variables so they can be accessed from views
    assign(:page, page)
    assign(:question_input, question_input)
    assign(:current_user, current_user)

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

  context "when the page is not a selection question" do
    it "contains the optional/mandatory radio question" do
      expect(rendered).to have_text(I18n.t("helpers.legend.pages_question_input.is_optional"))
      expect(rendered).to have_text(I18n.t("helpers.label.pages_question_input.is_optional_options.true"))
      expect(rendered).to have_text(I18n.t("helpers.label.pages_question_input.is_optional_options.false"))
      expect(rendered).to have_text(I18n.t("helpers.hint.pages_question_input.is_optional_options.true"))
    end
  end

  context "when the page is a selection question" do
    let(:answer_type) { "selection" }

    it "does not contain the optional/mandatory radio question" do
      expect(rendered).not_to have_text(I18n.t("pages.is_optional.legend"))
      expect(rendered).not_to have_text(I18n.t("pages.is_optional.options.mandatory"))
      expect(rendered).not_to have_text(I18n.t("pages.is_optional.options.optional"))
      expect(rendered).not_to have_text(I18n.t("helpers.hint.pages_question_input.is_optional_options.true"))
    end
  end
end
