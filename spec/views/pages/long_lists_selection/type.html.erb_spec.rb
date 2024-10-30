require "rails_helper"

describe "pages/long_lists_selection/type.html.erb", type: :view do
  let(:form) { build :form, id: 1 }
  let(:page) { build :page, routing_conditions: }
  let(:page_number) { 1 }
  let(:back_link_url) { "/a-back-link-url" }
  let(:selection_type_path) { "/a-path" }
  let(:only_one_option) { "true" }
  let(:draft_question) { build :draft_question, answer_type: "selection" }
  let(:routing_conditions) { [] }

  before do
    # # mock the form.page_number method
    allow(form).to receive(:page_number).and_return(page_number)

    # # mock the path helper
    without_partial_double_verification do
      allow(view).to receive_messages(form_pages_path: "/pages", current_form: form)
    end

    # # setup instance variables
    assign(:page, page)
    assign(:selection_type_path, selection_type_path)
    assign(:back_link_url, back_link_url)
    assign(:selection_type_input, Pages::LongListsSelection::TypeInput.new(only_one_option:, draft_question:))

    render(template: "pages/long_lists_selection/type")
  end

  describe "only one option radios" do
    context "when input object has value of true" do
      let(:only_one_option) { "true" }

      it "has 'Yes' radio selected" do
        expect(rendered).to have_checked_field("pages_long_lists_selection_type_input[only_one_option]", with: "true")
        expect(rendered).to have_unchecked_field("pages_long_lists_selection_type_input[only_one_option]", with: "false")
      end
    end

    context "when input object has value of false" do
      let(:only_one_option) { "false" }

      it "has 'No' radio selected" do
        expect(rendered).to have_checked_field("pages_long_lists_selection_type_input[only_one_option]", with: "false")
        expect(rendered).to have_unchecked_field("pages_long_lists_selection_type_input[only_one_option]", with: "true")
      end
    end

    context "when input object has no value set" do
      let(:only_one_option) { nil }

      it "does not have a radio option selected" do
        expect(rendered).to have_unchecked_field("pages_long_lists_selection_type_input[only_one_option]", with: "true")
        expect(rendered).to have_unchecked_field("pages_long_lists_selection_type_input[only_one_option]", with: "false")
      end
    end
  end

  describe "routing warning" do
    context "when creating a new question" do
      it "does not display a warning about routes being deleted if only one option changes" do
        expect(rendered).not_to have_selector(".govuk-notification-banner__content")
      end
    end

    context "when editing an existing question" do
      let(:form) { build :form, id: 1, pages: [page] }

      context "when no routing conditions set" do
        it "does not display a warning about routes being deleted if only one option changes" do
          expect(rendered).not_to have_selector(".govuk-notification-banner__content")
        end
      end

      context "when a routing condition is set" do
        let(:routing_conditions) { [(build :condition)] }

        it "displays a warning" do
          expect(rendered).to have_selector(".govuk-notification-banner__content")
        end
      end
    end
  end
end
