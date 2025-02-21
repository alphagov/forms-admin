require "rails_helper"

describe "pages/conditions/delete.html.erb" do
  let(:delete_condition_input) { Pages::DeleteConditionInput.new(form:, page:, record: condition) }
  let(:form) { build :form, :ready_for_routing, id: 1 }
  let(:condition) { build :condition, id: 1, routing_page_id: pages.first.id, check_page_id: pages.first.id, answer_value: "Wales", goto_page_id: pages.last.id }
  let(:secondary_skip_condition) { nil }
  let(:pages) { form.pages }
  let(:page) { pages.first }

  before do
    page.position = 1
    secondary_skip_condition
    render template: "pages/conditions/delete", locals: { delete_condition_input: }
  end

  it "sets the correct title" do
    expect(view.content_for(:title)).to eq(t("page_titles.routing_page_delete", question_number: page.position))
  end

  it "contains page heading and sub-heading" do
    expect(rendered).to have_css("h1 .govuk-caption-l", text: form.name)
    expect(rendered).to have_css("h1.govuk-heading-l", text: t("page_titles.routing_page_delete", question_number: page.position))
  end

  it "contains the condition details" do
    expect(rendered).to have_css(".govuk-summary-list__value", text: delete_condition_input.page.question_text)
    expect(rendered).to have_css(".govuk-summary-list__value", text: delete_condition_input.answer_value)
    expect(rendered).to have_css(".govuk-summary-list__value", text: delete_condition_input.goto_page_question_text)
  end

  it "has a submit button" do
    expect(rendered).to have_css("button[type='submit'].govuk-button", text: I18n.t("save_and_continue"))
  end

  context "when there is a validation error" do
    let(:delete_condition_input) do
      delete_condition_input = Pages::DeleteConditionInput.new(form:, page:, record: condition)
      delete_condition_input.confirm = nil
      delete_condition_input.validate
      delete_condition_input
    end

    it "renders an error summary" do
      expect(rendered).to have_css ".govuk-error-summary"
    end
  end

  context "when the condition does not have a secondary skip condition" do
    let(:secondary_skip_condition) { nil }

    it "does not render a warning" do
      expect(rendered).not_to have_css ".govuk-notification-banner"
    end
  end

  context "when the condition has a secondary skip condition" do
    let(:condition) do
      condition = build :condition, id: 1, routing_page_id: start_of_branches.id, check_page_id: start_of_branches.id, answer_value: "Wales", goto_page_id: start_of_second_branch.id
      start_of_branches.routing_conditions << condition
      condition
    end

    let(:secondary_skip_condition) do
      condition = build :condition, id: 2, routing_page_id: end_of_first_branch.id, check_page_id: start_of_branches.id, answer_value: nil, goto_page_id: end_of_branches.id
      end_of_first_branch.routing_conditions << condition
      condition
    end

    let(:start_of_branches) { pages.first }
    let(:end_of_first_branch) { pages.second }
    let(:start_of_second_branch) { pages.third }
    let(:end_of_branches) { pages.last }

    it "renders a warning" do
      expect(rendered).to have_css ".govuk-notification-banner", text: "If you delete this route, the route for any other answer will also be deleted"
    end

    context "when there is a validation error" do
      let(:delete_condition_input) do
        delete_condition_input = Pages::DeleteConditionInput.new(form:, page:, record: condition)
        delete_condition_input.confirm = nil
        delete_condition_input.validate
        delete_condition_input
      end

      it "renders an error summary" do
        expect(rendered).to have_css ".govuk-error-summary"
      end

      it "does not render a warning" do
        expect(rendered).not_to have_css ".govuk-notification-banner", text: "If you delete this route, the route for any other answer will also be deleted"
      end
    end
  end
end
