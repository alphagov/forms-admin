require "rails_helper"

describe "pages/selections_settings.html.erb", type: :view do
  let(:form) { build :form, id: 1 }
  let(:selections_settings_input) { build :selections_settings_input }
  let(:page) { OpenStruct.new(conditions:, answer_type: "selection", answer_settings:) }
  let(:answer_settings) { OpenStruct.new(only_one_option:) }
  let(:only_one_option) { "true" }
  let(:page_number) { 1 }
  let(:back_link_url) { "type-of-answers" }
  let(:selections_settings_path) { "edit" }
  let(:conditions) { [] }

  before do
    # # mock the form.page_number method
    allow(form).to receive(:page_number).and_return(page_number)

    # # mock the path helper
    without_partial_double_verification do
      allow(view).to receive(:form_pages_path).and_return("/type-of-answer")
      allow(view).to receive(:current_form).and_return(form)
    end

    # # setup instance variables
    assign(:page, page)
    assign(:selections_settings_path, selections_settings_path)
    assign(:back_link_url, back_link_url)
    assign(:selections_settings_input, selections_settings_input)

    render(template: "pages/selections_settings")
  end

  context "when editing an existing page" do
    let(:form) { build :form, id: 1, pages: [page] }

    context "when no routing conditions set" do
      it "does not display a warning about routes being deleted if only one option changes" do
        expect(rendered).not_to have_selector(".govuk-notification-banner__content")
      end
    end

    context "when a routing condition is set" do
      let(:conditions) { [(build :condition)] }

      it "displays a warning" do
        expect(rendered).to have_selector(".govuk-notification-banner__content")
      end
    end
  end
end
