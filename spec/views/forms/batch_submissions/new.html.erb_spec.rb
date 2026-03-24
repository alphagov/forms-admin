require "rails_helper"

describe "forms/batch_submissions/new.html.erb" do
  let(:send_daily_submission_batch) { true }
  let(:form) { build(:form, id: 1, send_daily_submission_batch:) }
  let(:batch_submissions_input) { Forms::BatchSubmissionsInput.new(form:).assign_form_values }

  before do
    assign(:batch_submissions_input, batch_submissions_input)
    render
  end

  it "sets the page title" do
    expect(view.content_for(:title)).to eq(t("page_titles.daily_submission_batch"))
  end

  it "has the correct heading" do
    expect(rendered).to have_css("h1", text: t("page_titles.daily_submission_batch"))
  end

  it "includes the expected fieldset legend" do
    expect(rendered).to have_css("legend", text: "Do you want to get a daily CSV of the previous day’s completed forms?")
  end

  it "includes the expected checkbox label" do
    expect(rendered).to have_css(".govuk-label", text: "Get a daily CSV of completed forms")
  end

  context "when the form has send_daily_submission_batch set to true" do
    let(:send_daily_submission_batch) { true }

    it "renders the checkbox as checked" do
      expect(rendered).to have_css("input.govuk-checkboxes__input[value='1'][checked]")
    end
  end

  context "when the form has send_daily_submission_batch set to false" do
    let(:send_daily_submission_batch) { false }

    it "renders the checkbox as unchecked" do
      expect(rendered).not_to have_css("input.govuk-checkboxes__input[value='1'][checked]")
    end
  end
end
