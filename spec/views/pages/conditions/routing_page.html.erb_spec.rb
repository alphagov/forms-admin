require "rails_helper"

describe "pages/conditions/routing_page.html.erb" do
  let(:form) { build :form, id: 1 }
  let(:pages) { build_list :page, 3, :with_selections_settings, form_id: 1 }
  let(:routing_page_input) { Pages::RoutingPageInput.new }
  let(:allowed_to_create_routes) { true }
  let(:all_routes_created) { false }

  before do
    without_partial_double_verification do
      allow(view).to receive(:policy).and_return(OpenStruct.new(can_add_page_routing_conditions?: allowed_to_create_routes))
    end

    allow(view).to receive(:form_pages_path).and_return("/forms/1/pages")
    allow(view).to receive(:routing_page_path).and_return("/forms/1/new-condition")
    allow(view).to receive(:set_routing_page_path).and_return("/forms/1/new-condition")
    allow(form).to receive(:qualifying_route_pages).and_return(pages)
    allow(form).to receive(:has_no_remaining_routes_available?).and_return(all_routes_created)

    render template: "pages/conditions/routing_page", locals: { form:, routing_page_input: }
  end

  it "contains page heading and sub-heading" do
    expect(rendered).to have_css("h1 .govuk-caption-l", text: form.name)
    expect(rendered).to have_css("h1.govuk-heading-l", text: t("page_titles.routing_page"))
  end

  it "contains body text" do
    expect(rendered).to have_css("p", text: t("routing_page.body_text"))
  end

  context "with fewer than 10 options" do
    it "contains a fieldset legend asking a user to select a question page" do
      expect(rendered).to have_css(".govuk-fieldset__legend", text: t("routing_page.legend_text"))
      expect(rendered).to have_css("div.govuk-hint", text: t("routing_page.legend_hint_text"))
    end

    it "includes a radio button for each page, with the page number and question text" do
      pages.each do |page|
        expect(rendered).to have_css(".govuk-radios__item", text: page.question_with_number)
      end
    end
  end

  context "with 10 options" do
    let(:pages) { build_list :page, 10, :with_selections_settings, form_id: 1 }

    it "contains a fieldset legend asking a user to select a question page" do
      expect(rendered).to have_css(".govuk-fieldset__legend", text: t("routing_page.legend_text"))
      expect(rendered).to have_css("div.govuk-hint", text: t("routing_page.legend_hint_text"))
    end

    it "includes a radio button for each page, with the page number and question text" do
      pages.each do |page|
        expect(rendered).to have_css(".govuk-radios__item", text: page.question_with_number)
      end
    end
  end

  context "with more than 10 options" do
    let(:pages) { build_list :page, 11, :with_selections_settings, form_id: 1 }

    it "contains a fieldset legend asking a user to select a question page" do
      expect(rendered).to have_css(".govuk-label", text: t("routing_page.legend_text"))
      expect(rendered).to have_css("div.govuk-hint", text: t("routing_page.legend_hint_text"))
    end

    it "has a select the default value" do
      expect(rendered).to have_css("select > option", text: I18n.t("routing_page.dropdown_default_text"))
    end

    it "includes a select option for each page, with the page number and question text" do
      pages.each do |page|
        expect(rendered).to have_text(page.question_with_number)
      end
    end
  end

  it "has a submit button" do
    expect(rendered).to have_css("button[type='submit'].govuk-button", text: "Continue")
  end

  context "when form doesn't meet requirements for creating a route" do
    let(:allowed_to_create_routes) { false }

    it "explains to the user what is required for them to be able to add a new routes" do
      guidance = Capybara.string(I18n.t("routing_page.routing_requirements_not_met_html")).text(normalize_ws: true)
      expect(rendered).to have_text(guidance, normalize_ws: true)
    end

    context "when all qualifying questions have a route" do
      let(:all_routes_created) { true }

      it "explains to the user that they have created all available routes" do
        guidance = Capybara.string(I18n.t("routing_page.no_remaining_routes").to_s).text(normalize_ws: true)
        expect(rendered).to have_text(guidance, normalize_ws: true)
      end
    end
  end
end
