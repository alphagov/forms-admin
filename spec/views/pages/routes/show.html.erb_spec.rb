require "rails_helper"

describe "pages/routes/show.html.erb" do
  let(:form) { build :form, id: 1, pages: [page] }
  let(:pages) { [page] }
  let(:page) { build :page, id: 1, position: 1, routing_conditions: [build(:condition)] }
  let(:routes) { PageRoutesService.new(form:, pages:, page:).routes }

  let(:route_cards) do
    [
      {
        card: { title: "route 1" },
        rows: [
          { key: { text: "route 1 key" }, value: { text: "route 1 value" } },
        ],
      },
    ]
  end

  let(:route_summary_card_data_service) { instance_double(RouteSummaryCardDataPresenter, summary_card_data: route_cards) }

  before do
    allow(RouteSummaryCardDataPresenter).to receive(:new).and_return(route_summary_card_data_service)
    render template: "pages/routes/show", locals: { current_form: form, page:, pages:, routes:, back_link_url: "/back" }
  end

  it "has the correct title" do
    expect(view.content_for(:title)).to have_content("Question 1’s routes")
  end

  it "has the correct back link" do
    expect(view.content_for(:back_link)).to have_link(I18n.t("pages.go_to_your_questions"), href: "/back")
  end

  it "has the correct heading and caption" do
    expect(rendered).to have_selector("h1", text: form.name)
    expect(rendered).to have_selector("h1", text: I18n.t("page_titles.routes_show", position: page.position))
  end

  it "shows the page title as a summary list" do
    expect(rendered).to have_css(".govuk-summary-list__key", text: "Question #{page.position}")
    expect(rendered).to have_css(".govuk-summary-list__value", text: page.question_text)
  end

  it "shows the correct route cards" do
    expect(rendered).to have_css(".govuk-summary-list__key", text: "route 1 key")
    expect(rendered).to have_css(".govuk-summary-list__value", text: "route 1 value")
  end

  it "has a back to questions link" do
    expect(rendered).to have_link(I18n.t("pages.go_to_your_questions"), href: form_pages_path(form.id))
  end

  context "when the page has a skip route" do
    include_context "with pages with routing"

    let(:page) { page_with_skip_route }

    it "does not have a link to delete all routes" do
      expect(rendered).not_to have_link(I18n.t("page_route_card.delete_route"), href: delete_routes_path(form.id, page.id))
    end
  end

  context "when the page has a skip and a secondary skip" do
    include_context "with pages with routing"

    let(:page) { page_with_skip_and_secondary_skip }

    it "has a link to delete all routes" do
      expect(rendered).to have_link(I18n.t("page_route_card.delete_route"), href: delete_routes_path(form.id, page.id))
    end
  end
end
