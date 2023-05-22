require "rails_helper"

describe "pages/conditions/routing_page.html.erb" do
  let(:form) { build :form, id: 1 }
  let(:pages) { build_list :page, 3, :with_selections_settings, form_id: 1 }

  before do
    allow(view).to receive(:form_pages_path).and_return("/forms/1/pages")
    allow(view).to receive(:routing_page_path).and_return("/forms/1/new-condition")
    allow(view).to receive(:set_routing_page_path).and_return("/forms/1/new-condition")
    allow(form).to receive(:qualifying_route_pages).and_return(pages)

    render template: "pages/conditions/routing_page", locals: { form: }
  end

  it "contains page heading and sub-heading" do
    expect(rendered).to have_css("h1 .govuk-caption-l", text: form.name)
    expect(rendered).to have_css("h1.govuk-heading-l", text: t("page_titles.routing_page"))
  end

  it "contains body text" do
    expect(rendered).to have_css("p.govuk-body", text: t("routing_page.body_text"))
  end

  context "with fewer than 10 options" do
    it "contains a fieldset legend asking a user to select a question page" do
      expect(rendered).to have_css(".govuk-fieldset__legend", text: t("routing_page.legend_text"))
      expect(rendered).to have_css("div.govuk-hint", text: t("routing_page.legend_hint_text"))
    end

    it "has a radio option for each routing pages" do
      expect(rendered).to have_css(".govuk-radios__item", count: pages.length)
    end
  end

  context "with 10 options" do
    let(:pages) { build_list :page, 10, :with_selections_settings, form_id: 1 }

    it "contains a fieldset legend asking a user to select a question page" do
      expect(rendered).to have_css(".govuk-fieldset__legend", text: t("routing_page.legend_text"))
      expect(rendered).to have_css("div.govuk-hint", text: t("routing_page.legend_hint_text"))
    end

    it "has a radio option for each routing pages" do
      expect(rendered).to have_css(".govuk-radios__item", count: pages.length)
    end
  end

  context "with more than 10 options" do
    let(:pages) { build_list :page, 11, :with_selections_settings, form_id: 1 }

    it "contains a fieldset legend asking a user to select a question page" do
      expect(rendered).to have_css(".govuk-label", text: t("routing_page.legend_text"))
      expect(rendered).to have_css("div.govuk-hint", text: t("routing_page.legend_hint_text"))
    end

    it "has a select option for each routing pages" do
      expect(rendered).to have_css("select > option", count: pages.length)
    end

    it "includes the page number and question text" do
      expect(rendered).to have_text(pages.first.question_with_number)
    end
  end

  it "has a submit button" do
    expect(rendered).to have_css("button[type='submit'].govuk-button", text: "Continue")
  end
end
