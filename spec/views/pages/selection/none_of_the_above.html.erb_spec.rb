require "rails_helper"

describe "pages/selection/none_of_the_above.html.erb", type: :view do
  let(:form) { create :form }
  let(:page) { build :page }
  let(:selection_options) { [{ name: "Option 1" }, { name: "Option 2" }] }
  let(:answer_settings) { { selection_options: } }
  let(:draft_question) { build :draft_question, answer_type: "selection", answer_settings: }
  let(:question_text) { nil }
  let(:is_optional) { nil }
  let(:none_of_the_above_input) { Pages::Selection::NoneOfTheAboveInput.new(question_text:, is_optional:, draft_question:) }

  before do
    # # mock the form.page_number method
    allow(form).to receive(:page_number).and_return(1)

    # # mock the path helper
    without_partial_double_verification do
      allow(view).to receive_messages(form_pages_path: "/pages", current_form: form)
    end

    # # setup instance variables
    assign(:page, page)
    assign(:none_of_the_above_path, "/a-path")
    assign(:back_link_url, "/a-back-link-url")
    assign(:none_of_the_above_input, none_of_the_above_input)

    render(template: "pages/selection/none_of_the_above")
  end

  describe "preamble text" do
    context "when there are fewer than 30 selection options" do
      it "displays the correct preamble text" do
        expect(rendered).to have_content(I18n.t("selection_none_of_the_above.preamble"))
      end
    end

    context "when there are more than 30 selection options" do
      let(:selection_options) { (1..31).to_a.map { |i| { name: i.to_s } } }

      it "displays the correct preamble text for bulk options" do
        expect(rendered).to have_content(I18n.t("selection_none_of_the_above.preamble_more_than_30_options"))
      end
    end
  end

  describe "is optional radios" do
    it "contains a radio options for whether the question is optional" do
      expect(rendered).to have_css("fieldset", text: I18n.t("helpers.legend.pages_selection_none_of_the_above_input.is_optional"))
      expect(rendered).to have_field(I18n.t("helpers.label.pages_selection_none_of_the_above_input.is_optional_options.false"), type: "radio")
      expect(rendered).to have_field(I18n.t("helpers.label.pages_selection_none_of_the_above_input.is_optional_options.true"), type: "radio")
    end

    context "when input object has value of true" do
      let(:is_optional) { "true" }

      it "has 'Yes' radio selected" do
        expect(rendered).to have_checked_field("pages_selection_none_of_the_above_input[is_optional]", with: "true")
        expect(rendered).to have_unchecked_field("pages_selection_none_of_the_above_input[is_optional]", with: "false")
      end
    end

    context "when input object has value of false" do
      let(:is_optional) { "false" }

      it "has 'No' radio selected" do
        expect(rendered).to have_checked_field("pages_selection_none_of_the_above_input[is_optional]", with: "false")
        expect(rendered).to have_unchecked_field("pages_selection_none_of_the_above_input[is_optional]", with: "true")
      end
    end

    context "when input object has no value set" do
      let(:is_optional) { nil }

      it "does not have a radio option selected" do
        expect(rendered).to have_unchecked_field("pages_selection_none_of_the_above_input[is_optional]", with: "true")
        expect(rendered).to have_unchecked_field("pages_selection_none_of_the_above_input[is_optional]", with: "false")
      end
    end
  end
end
