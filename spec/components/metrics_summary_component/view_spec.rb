require "rails_helper"

RSpec.describe MetricsSummaryComponent::View, type: :component, feature_metrics_for_form_creators_enabled: true do
  let(:metrics_data) { nil }
  let(:metrics_summary) { described_class.new(metrics_data) }

  before do
    render_inline(metrics_summary)
  end

  it "has the correct start and end dates" do
    expect(metrics_summary.start_date).to eq(1.week.ago.to_date)
    expect(metrics_summary.end_date).to eq(1.day.ago.to_date)
  end

  it "renders the start and end dates" do
    expect(page).to have_text(metrics_summary.formatted_date_range)
  end

  describe "#formatted_date_range" do
    context "when the start and end dates are in different years" do
      before do
        metrics_summary.start_date = Time.zone.local(2023, 12, 25)
        metrics_summary.end_date = Time.zone.local(2024, 0o1, 0o2)
      end

      it "returns the full start and end dates" do
        expect(metrics_summary.formatted_date_range).to eq("25 December 2023 to 2 January 2024")
      end
    end

    context "when the start and end dates are in the same year" do
      before do
        metrics_summary.start_date = Time.zone.local(2023, 10, 31)
        metrics_summary.end_date = Time.zone.local(2023, 11, 8)
      end

      it "returns the start date without the year" do
        expect(metrics_summary.formatted_date_range).to eq("31 October to 8 November 2023")
      end
    end
  end

  context "when metrics_data is null" do
    it "returns the 'error loading data' message" do
      expect(metrics_summary.error_message).to eq(I18n.t("metrics_summary.errors.error_loading_data_html"))
    end

    it "renders the error message" do
      expect(page).to have_text(Nokogiri::HTML(metrics_summary.error_message).text)
    end
  end

  context "when form is too new" do
    let(:metrics_data) { { weekly_submissions: 0, form_is_new: true } }

    it "returns the 'new form' message" do
      expect(metrics_summary.error_message).to eq(I18n.t("metrics_summary.errors.new_form_html"))
    end

    it "renders the error message" do
      expect(page).to have_text(Nokogiri::HTML(metrics_summary.error_message).text)
    end
  end

  context "when metrics_data has a value for weekly submissions" do
    let(:metrics_data) { { weekly_submissions: 1235, form_is_new: false } }

    it "returns the metrics component with the number of submissions" do
      expect(metrics_summary.weekly_submissions).to eq(metrics_data[:weekly_submissions])
    end

    it "renders the description text" do
      expect(page).to have_text(I18n.t("metrics_summary.description"))
    end

    it "renders the weekly submissions figure" do
      expect(page).to have_text("#{I18n.t('metrics_summary.forms_submitted')} #{metrics_data[:weekly_submissions]}")
    end
  end
end
