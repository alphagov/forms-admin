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
    allow(view).to receive(:delete_condition_path).and_return("/forms/1/pages/1/conditions/2/delete")
    allow(form).to receive(:qualifying_route_pages).and_return(pages)
    condition_form.check_errors_from_api

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

  it "has a delete route link" do
    expect(rendered).to have_link(text: "Delete question route", href: "/forms/1/pages/1/conditions/2/delete")
  end

  context "with a validation error" do
    let(:condition) { build :condition, :with_answer_value_missing, id: 1, routing_page_id: 1, check_page_id: 1, goto_page_id: 3 }

    it "has an error link that matches the field with errors" do
      field_id = "pages-conditions-form-answer-value-field-error"

      expect(rendered).to have_css(".govuk-error-summary")
      expect(rendered).to have_link(I18n.t("activemodel.errors.models.pages/conditions_form.attributes.answer_value.answer_value_doesnt_exist", href: "##{field_id}"))
      expect(rendered).to have_css("##{field_id}")
    end
  end
end
