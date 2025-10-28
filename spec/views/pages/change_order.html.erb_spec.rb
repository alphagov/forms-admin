require "rails_helper"

describe "pages/change_order.html.erb", type: :view do
  let(:form) { create :form, :with_pages, pages_count: 3 }
  let(:change_order_input) { Pages::ChangeOrderInput.new(form:, page_position_params:, confirm:) }
  let(:show_banner) { false }
  let(:confirm) { "yes" }

  let(:page_position_params) { nil }

  before do
    assign :change_order_input, change_order_input
    render(locals: { show_banner: })
  end

  it "has an input for each page in the form" do
    expect(rendered).to have_field("pages_change_order_input[position_for_page_#{form.pages[0].id}]")
    expect(rendered).to have_field("pages_change_order_input[position_for_page_#{form.pages[1].id}]")
    expect(rendered).to have_field("pages_change_order_input[position_for_page_#{form.pages[2].id}]")
  end

  context "when show banner is true" do
    let(:show_banner) { true }

    it "shows a banner" do
      expect(rendered).to have_css(".govuk-notification-banner__heading", text: "You need to save this question order if you want to keep these changes")
    end
  end

  context "when there are validation errors" do
    let(:confirm) { nil }
    let(:page_position_params) do
      {
        "position_for_page_#{form.pages[0].id}".to_sym => "0",
        "position_for_page_#{form.pages[1].id}".to_sym => "",
        "position_for_page_#{form.pages[2].id}".to_sym => "",
      }
    end

    before do
      change_order_input.validate
      render(locals: { show_banner: })
    end

    it "shows the error summary" do
      expect(rendered).to have_css ".govuk-error-summary", text: /Position must be a whole number between 1 and 1000/
      expect(rendered).to have_css ".govuk-error-summary", text: /Select ‘Yes, save this question order’ to save your changes/
    end

    it "the inline error message" do
      expect(rendered).to have_css "#pages-change-order-input-position-for-page-#{form.pages[0].id}-error.govuk-error-message", text: "Position must be a whole number between 1 and 1000"
      expect(rendered).to have_css "#pages-change-order-input-confirm-error.govuk-error-message", text: "Select ‘Yes, save this question order’ to save your changes"
    end

    it "prefills existing position values from the params" do
      expect(rendered).to have_field("pages_change_order_input[position_for_page_#{form.pages[0].id}]", with: "0")
    end
  end
end
