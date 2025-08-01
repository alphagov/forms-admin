require "rails_helper"

describe "pages/conditions/edit.html.erb" do
  let(:condition_input) { Pages::ConditionsInput.new(form:, page:, record: condition) }
  let(:form) { build :form, :ready_for_routing, id: 1 }
  let(:group) { build :group }
  let(:condition) { build :condition, id: 1, routing_page_id: 1, check_page_id: 1, answer_value: "Wales", goto_page_id: 3 }
  let(:pages) { form.pages << page }
  let(:secondary_skip) { false }
  let(:page) do
    build :page,
          form_id: form.id,
          is_optional: "false",
          answer_type: "selection",
          answer_settings: OpenStruct.new(only_one_option: "true",
                                          selection_options: [OpenStruct.new(attributes: { name: "Option 1" }),
                                                              OpenStruct.new(attributes: { name: "Option 2" })])
  end

  before do
    page.position = 1
    allow(view).to receive_messages(form_pages_path: "/forms/1/pages", create_condition_path: "/forms/1/pages/1/conditions/new", delete_condition_path: "/forms/1/pages/1/conditions/2/delete")
    allow(form).to receive_messages(group: group, qualifying_route_pages: pages)
    allow(condition_input).to receive(:secondary_skip?).and_return(secondary_skip)
    allow(FormRepository).to receive_messages(pages:)
    condition_input.check_errors_from_api

    render template: "pages/conditions/edit", locals: { condition_input: }
  end

  it "sets the correct title" do
    expect(view.content_for(:title)).to eq("Edit route 1")
  end

  it "contains page heading and sub-heading" do
    expect(rendered).to have_css("h1 .govuk-caption-l", text: "Question 1’s routes")
    expect(rendered).to have_css("h1.govuk-heading-l", text: "Edit route 1")
  end

  it "does not contain a change action for editing the question of the route" do
    expect(rendered).not_to have_css(".govuk-summary-list__row .govuk-summary-list__actions")
  end

  it "has a submit button" do
    expect(rendered).to have_css("button[type='submit'].govuk-button", text: I18n.t("save_and_continue"))
  end

  it "has a delete route link" do
    expect(rendered).to have_link(text: "Delete route", href: "/forms/1/pages/1/conditions/2/delete")
  end

  context "with a validation error" do
    let(:condition) { build :condition, :with_answer_value_missing, id: 1, routing_page_id: 1, check_page_id: 1, goto_page_id: 3 }

    it "has an error link that matches the field with errors" do
      field_id = "pages-conditions-input-answer-value-field-error"

      expect(rendered).to have_css(".govuk-error-summary")
      expect(rendered).to have_link(I18n.t("activemodel.errors.models.pages/conditions_input.attributes.answer_value.answer_value_doesnt_exist", href: "##{field_id}"))
      expect(rendered).to have_css("##{field_id}")
    end
  end

  context "when the condition does not have an exit page" do
    let(:condition) { build :condition, id: 1, routing_page_id: 1, check_page_id: 1, answer_value: "Wales", goto_page_id: 3 }

    it "has an 'add exit page' option" do
      expect(rendered).to have_content("Add an exit page")
    end
  end

  context "when the condition has an exit page" do
    let(:condition) { build :condition, :with_exit_page, id: 1, routing_page_id: 1, check_page_id: 1, answer_value: "Wales" }

    it "has the exit page heading" do
      expect(rendered).to have_content(condition.exit_page_heading)
    end
  end

  context "when the page already has a secondary skip route" do
    let(:secondary_skip) { true }

    it "does not have an 'add exit page' option" do
      expect(rendered).not_to have_content("Add an exit page")
    end
  end
end
