require "rails_helper"

describe "forms/batch_submissions/new.html.erb" do
  let(:send_daily_submission_batch) { true }
  let(:send_weekly_submission_batch) { true }
  let(:form) { build(:form, id: 1, send_daily_submission_batch:, send_weekly_submission_batch:) }
  let(:batch_submissions_input) { Forms::BatchSubmissionsInput.new(form:).assign_form_values }

  before do
    assign(:batch_submissions_input, batch_submissions_input)
    render
  end

  context "when the weekly submissions feature is disabled", feature_weekly_submission_emails_enabled: false do
    it "sets the page title" do
      expect(view.content_for(:title)).to eq(t("page_titles.daily_submission_batch"))
    end

    it "has the correct heading" do
      expect(rendered).to have_css("h1", text: t("page_titles.daily_submission_batch"))
    end

    it "includes the expected body text" do
      expect(rendered).to include(t("forms.batch_submissions.new.weekly_disabled_body_html"))
    end

    it "includes the expected fieldset legend" do
      expect(rendered).to have_css("legend", text: t("forms.batch_submissions.new.weekly_disabled_fieldset_legend"))
    end

    it "has a checkbox for daily submissions batches" do
      expect(rendered).to have_css("input[type='checkbox'][value='daily']")
    end

    it "does not have a checkbox for weekly submissions batches" do
      expect(rendered).not_to have_css("input[type='checkbox'][value='weekly']")
    end

    it "includes the expected checkbox label" do
      expect(rendered).to have_css(".govuk-label[for='forms-batch-submissions-input-batch-frequencies-daily-field']", text: "Get a daily CSV of completed forms")
    end

    context "when the form has send_daily_submission_batch set to true" do
      let(:send_daily_submission_batch) { true }

      it "renders the checkbox as checked" do
        expect(rendered).to have_checked_field("forms-batch-submissions-input-batch-frequencies-daily-field")
      end
    end
  end

  context "when the weekly submissions feature is enabled", :feature_weekly_submission_emails_enabled do
    it "sets the page title" do
      expect(view.content_for(:title)).to eq(t("page_titles.submission_batches"))
    end

    it "has the correct heading" do
      expect(rendered).to have_css("h1", text: t("page_titles.submission_batches"))
    end

    it "includes the expected body text" do
      expect(rendered).to include(t("forms.batch_submissions.new.body_html"))
    end

    it "includes the expected fieldset legend" do
      expect(rendered).to have_css("legend", text: "Do you want to get a daily or weekly CSV of submissions to this form?")
    end

    it "has a checkbox for daily submissions batches" do
      expect(rendered).to have_css("input[type='checkbox'][value='daily']")
    end

    it "has a checkbox for weekly submissions batches" do
      expect(rendered).to have_css("input[type='checkbox'][value='weekly']")
    end

    it "includes the expected checkbox label" do
      expect(rendered).to have_css(".govuk-label[for='forms-batch-submissions-input-batch-frequencies-daily-field']", text: "Get a daily CSV of submissions")
    end

    context "when the form has send_daily_submission_batch set to true" do
      let(:send_daily_submission_batch) { true }

      it "renders the checkbox as checked" do
        expect(rendered).to have_checked_field("forms-batch-submissions-input-batch-frequencies-daily-field")
      end
    end

    context "when the form has send_weekly_submission_batch set to true" do
      let(:send_weekly_submission_batch) { true }

      it "renders the checkboxes as unchecked" do
        expect(rendered).to have_checked_field("forms-batch-submissions-input-batch-frequencies-weekly-field")
      end
    end

    context "when the form has batch submissions disabled" do
      let(:send_daily_submission_batch) { false }
      let(:send_weekly_submission_batch) { false }

      it "renders the checkboxes as unchecked" do
        expect(rendered).to have_unchecked_field("forms-batch-submissions-input-batch-frequencies-daily-field")
        expect(rendered).to have_unchecked_field("forms-batch-submissions-input-batch-frequencies-weekly-field")
      end
    end
  end
end
