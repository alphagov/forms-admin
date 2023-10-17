require "rails_helper"

RSpec.describe MetricsSummaryComponent::View, type: :component, feature_metrics_for_form_creators_enabled: true do
  let(:metrics_data) { nil }
  let(:form_live_date) { 7.days.ago.to_date }
  let(:metrics_summary) { described_class.new(form_live_date, metrics_data) }

  before do
    render_inline(metrics_summary)
  end

  it "has the correct start and end dates" do
    expect(metrics_summary.start_date).to eq(1.week.ago.to_date)
    expect(metrics_summary.end_date).to eq(1.day.ago.to_date)
  end

  it "renders the start and end dates" do
    expect(render_inline(metrics_summary).to_html).to include(metrics_summary.formatted_date_range)
  end

  it "renders the number of days spanned" do
    expect(page).to have_css("h2", text: metrics_summary.number_of_days)
  end

  describe "#formatted_date_range" do
    context "when the start and end dates are in different years" do
      before do
        metrics_summary.start_date = Time.zone.local(2023, 12, 25)
        metrics_summary.end_date = Time.zone.local(2024, 0o1, 0o2)
      end

      it "returns the full start and end dates" do
        expect(metrics_summary.formatted_date_range).to eq("<span class=\"app-metrics__date\">25 December 2023</span> to <span class=\"app-metrics__date\">2 January 2024</span>")
      end
    end

    context "when the start and end dates are in the same year" do
      before do
        metrics_summary.start_date = Time.zone.local(2023, 10, 31)
        metrics_summary.end_date = Time.zone.local(2023, 11, 8)
      end

      it "returns the start date without the year" do
        expect(metrics_summary.formatted_date_range).to eq("<span class=\"app-metrics__date\">31 October</span> to <span class=\"app-metrics__date\">8 November 2023</span>")
      end
    end
  end

  describe "#calculate_percentage" do
    it "returns nil if the total argument is zero" do
      expect(metrics_summary.calculate_percentage(168, 0)).to eq(nil)
    end

    it "returns the percentage rounded to the nearest integer" do
      expect(metrics_summary.calculate_percentage(168, 1000)).to eq(17)
      expect(metrics_summary.calculate_percentage(253, 1000)).to eq(25)
      expect(metrics_summary.calculate_percentage(965, 1000)).to eq(97)
    end
  end

  describe "#number_of_days" do
    it "returns the number of days between the start date and today's date, inclusive" do
      metrics_summary.end_date = 1.day.ago.to_date

      expect(metrics_summary.number_of_days).to eq(7)
    end
  end

  describe "#description" do
    context "when there is a week's worth of metrics" do
      it "returns the complete week description translation" do
        expect(metrics_summary.description).to eq(I18n.t("metrics_summary.description.complete_week"))
      end
    end

    context "when there is less than a week's worth of metrics" do
      let(:form_live_date) { 3.days.ago.to_date }

      it "returns the incomplete week description translation" do
        expect(metrics_summary.description).to eq(I18n.t("metrics_summary.description.incomplete_week"))
      end
    end
  end

  context "when metrics_data is null" do
    it "returns the 'error loading data' message" do
      expect(metrics_summary.error_message).to eq(I18n.t("metrics_summary.errors.error_loading_data_html"))
    end

    it "renders the error message" do
      expect(render_inline(metrics_summary).to_html).to include(metrics_summary.error_message)
    end
  end

  context "when form is too new" do
    let(:form_live_date) { Time.zone.today }
    let(:metrics_data) { { weekly_submissions: 0 } }

    it "returns the 'new form' message" do
      expect(metrics_summary.error_message).to eq(I18n.t("metrics_summary.errors.new_form_html"))
    end

    it "renders the error message" do
      expect(render_inline(metrics_summary).to_html).to include(metrics_summary.error_message)
    end

    it "renders the heading without date information" do
      expect(page).to have_css("h2", exact_text: I18n.t("metrics_summary.heading_without_dates"))
    end
  end

  context "when form went live yesterday" do
    let(:form_live_date) { 1.day.ago.to_date }
    let(:metrics_data) { { weekly_submissions: 269, weekly_starts: 1000 } }
    let(:forms_started_but_not_completed) { metrics_data[:weekly_starts] - metrics_data[:weekly_submissions] }
    let(:percentage) { metrics_summary.calculate_percentage(metrics_data[:weekly_submissions], metrics_data[:weekly_starts]) }

    it "renders the completion rate percentage" do
      expect(page).to have_text("#{I18n.t('metrics_summary.completion_rate')} #{percentage}%")
    end

    it "returns the metrics component with the number of submissions" do
      expect(metrics_summary.weekly_submissions).to eq(metrics_data[:weekly_submissions])
    end

    it "returns the metrics component with the number of forms started but not completed" do
      expect(metrics_summary.weekly_started_but_not_completed).to eq(forms_started_but_not_completed)
    end

    it "renders the incomplete week description text" do
      expect(page).to have_text(I18n.t("metrics_summary.description.incomplete_week"))
    end

    it "renders the weekly submissions figure" do
      expect(page).to have_text("#{I18n.t('metrics_summary.forms_submitted')} #{metrics_data[:weekly_submissions]}")
    end

    it "renders the forms started but not completed figure" do
      expect(page).to have_text("#{I18n.t('metrics_summary.forms_started_but_not_completed')} #{forms_started_but_not_completed}")
    end

    it "renders the heading without date information" do
      expect(page).to have_css("h2", exact_text: I18n.t("metrics_summary.heading_with_single_date", date: form_live_date.strftime("%e %B %Y").strip))
    end
  end

  context "when weekly starts is zero" do
    let(:metrics_data) { { weekly_submissions: 0, weekly_starts: 0 } }

    it "returns the 'no starts' message" do
      expect(metrics_summary.error_message).to eq(I18n.t("metrics_summary.errors.no_submissions_html"))
    end

    it "renders the error message" do
      expect(render_inline(metrics_summary).to_html).to include(metrics_summary.error_message)
    end
  end

  context "when weekly starts is not zero" do
    let(:metrics_data) { { weekly_submissions: 269, weekly_starts: 1000 } }
    let(:forms_started_but_not_completed) { metrics_data[:weekly_starts] - metrics_data[:weekly_submissions] }
    let(:percentage) { metrics_summary.calculate_percentage(metrics_data[:weekly_submissions], metrics_data[:weekly_starts]) }

    it "renders the completion rate percentage" do
      expect(page).to have_text("#{I18n.t('metrics_summary.completion_rate')} #{percentage}%")
    end

    it "returns the metrics component with the number of submissions" do
      expect(metrics_summary.weekly_submissions).to eq(metrics_data[:weekly_submissions])
    end

    it "returns the metrics component with the number of forms started but not completed" do
      expect(metrics_summary.weekly_started_but_not_completed).to eq(forms_started_but_not_completed)
    end

    it "renders the complete week description text" do
      expect(page).to have_text(I18n.t("metrics_summary.description.complete_week"))
    end

    it "renders the weekly submissions figure" do
      expect(page).to have_text("#{I18n.t('metrics_summary.forms_submitted')} #{metrics_data[:weekly_submissions]}")
    end

    it "renders the forms started but not completed figure" do
      expect(page).to have_text("#{I18n.t('metrics_summary.forms_started_but_not_completed')} #{forms_started_but_not_completed}")
    end
  end

  context "when there are fewer than 7 days worth of data" do
    let(:metrics_data) { { weekly_submissions: 269, weekly_starts: 1000 } }
    let(:forms_started_but_not_completed) { metrics_data[:weekly_starts] - metrics_data[:weekly_submissions] }
    let(:percentage) { metrics_summary.calculate_percentage(metrics_data[:weekly_submissions], metrics_data[:weekly_starts]) }
    let(:form_live_date) { 3.days.ago.to_date }

    it "renders the completion rate percentage" do
      expect(page).to have_text("#{I18n.t('metrics_summary.completion_rate')} #{percentage}%")
    end

    it "returns the metrics component with the number of submissions" do
      expect(metrics_summary.weekly_submissions).to eq(metrics_data[:weekly_submissions])
    end

    it "returns the metrics component with the number of forms started but not completed" do
      expect(metrics_summary.weekly_started_but_not_completed).to eq(forms_started_but_not_completed)
    end

    it "renders the incomplete week description text" do
      expect(page).to have_text(I18n.t("metrics_summary.description.incomplete_week"))
    end

    it "renders the weekly submissions figure" do
      expect(page).to have_text("#{I18n.t('metrics_summary.forms_submitted')} #{metrics_data[:weekly_submissions]}")
    end

    it "renders the forms started but not completed figure" do
      expect(page).to have_text("#{I18n.t('metrics_summary.forms_started_but_not_completed')} #{forms_started_but_not_completed}")
    end
  end
end
