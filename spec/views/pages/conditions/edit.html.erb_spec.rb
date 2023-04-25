require "rails_helper"

describe "pages/conditions/edit.html.erb" do
  let(:condition_form) { Pages::ConditionsForm.new(form:, page:, record: condition) }
  let(:form) { build :form, :ready_for_routing, id: 1 }
  let(:condition) { build :condition, id: 1, routing_page_id: 1, check_page_id: 1, answer_value: "Wales", goto_page_id: 3 }
  let(:pages) { form.pages }
  let(:page) { pages.first }

  before do
    page.position = 1
    allow(view).to receive(:form_pages_path).and_return("/forms/1/pages")
    allow(view).to receive(:create_condition_path).and_return("/forms/1/pages/1/conditions/new")
    allow(form).to receive(:qualifying_route_pages).and_return(pages)

    render template: "pages/conditions/edit", locals: { condition_form: }
  end

  it "contains page heading and sub-heading" do
    expect(rendered).to have_css("h1 .govuk-caption-l", text: form.name)
    expect(rendered).to have_css("h1.govuk-heading-l", text: t("page_titles.routing_page_edit", question_position: page.position))
  end

  it "does not contain a change action for editing the question of the route" do
    expect(rendered).not_to have_css(".govuk-summary-list__row .govuk-summary-list__actions")
  end

  it "has a submit button" do
    expect(rendered).to have_css("button[type='submit'].govuk-button", text: I18n.t("save_and_continue"))
  end
end
