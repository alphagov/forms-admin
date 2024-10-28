require "rails_helper"

describe "pages/routes/show.html.erb" do
  let(:form) { build :form, id: 1, pages: [page] }
  let(:page) { build :page, id: 1, position: 1 }

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

  let(:route_summary_card_data_service) { instance_double(RouteSummaryCardDataService, summary_card_data: route_cards) }

  before do
    allow(RouteSummaryCardDataService).to receive(:call).and_return(route_summary_card_data_service)
    render template: "pages/routes/show", locals: { current_form: form, page:, pages: form.pages, back_link_url: "/back" }
  end

  it "has the correct title" do
    expect(view.content_for(:title)).to have_content("Edit question 1's routes")
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
    expect(rendered).to have_css(".govuk-summary-list__value", text: "\"#{page.question_text}\"")
  end

  it "shows the correct route cards" do
    expect(rendered).to have_css(".govuk-summary-list__key", text: "route 1 key")
    expect(rendered).to have_css(".govuk-summary-list__value", text: "route 1 value")
  end

  it "has a back to questions link" do
    expect(rendered).to have_link(I18n.t("pages.go_to_your_questions"), href: form_pages_path(form.id))
  end
end
