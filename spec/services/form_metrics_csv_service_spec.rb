require "rails_helper"

describe FormMetricsCsvService do
  let(:form_id) { 3 }

  let(:cloud_watch_service_double) { instance_double(CloudWatchService, daily_metrics_data:) }
  let(:daily_metrics_data) { {} }
  let(:first_made_live_at) { 1.week.ago }

  before do
    allow(CloudWatchService).to receive(:new).and_return(cloud_watch_service_double)
  end

  around do |example|
    travel_to(Time.zone.local(2021, 6, 15, 4, 30, 0)) do
      example.run
    end
  end

  describe "#csv" do
    context "when the first_made_live_at is more than 14 months ago" do
      let(:first_made_live_at) { 16.months.ago }

      it "calls CloudWatchService with a start date 14 months ago" do
        expect(cloud_watch_service_double).to receive(:daily_metrics_data).with(14.months.ago.midnight)
        described_class.csv(form_id:, first_made_live_at:)
      end

      it "generates a CSV with 14 months of rows" do
        csv = described_class.csv(form_id:, first_made_live_at:)
        rows = CSV.parse(csv)
        expect(rows.length).to eq(427) # 456 days + header row
      end
    end

    context "when the first_made_live_at is less than 14 months ago" do
      let(:first_made_live_at) { 1.month.ago }

      it "calls CloudWatchService with a start date 14 months ago" do
        expect(cloud_watch_service_double).to receive(:daily_metrics_data).with(first_made_live_at.midnight)
        described_class.csv(form_id:, first_made_live_at:)
      end

      it "generates a CSV with a row count corresponding to the first_made_live_at date" do
        csv = described_class.csv(form_id:, first_made_live_at:)
        rows = CSV.parse(csv)
        expect(rows.length).to eq(32) # 456 days + header row
      end
    end

    context "when there is no metrics data" do
      it "generates CSV rows with zero data" do
        csv = described_class.csv(form_id:, first_made_live_at:)
        rows = CSV.parse(csv)
        expect(rows).to eq([
          ["Date", "Started", "Completed", "Completion rate (%)", "Started but not completed"],
          ["14/06/2021", "0", "0", "No starts", "0"],
          ["13/06/2021", "0", "0", "No starts", "0"],
          ["12/06/2021", "0", "0", "No starts", "0"],
          ["11/06/2021", "0", "0", "No starts", "0"],
          ["10/06/2021", "0", "0", "No starts", "0"],
          ["09/06/2021", "0", "0", "No starts", "0"],
          ["08/06/2021", "0", "0", "No starts", "0"],
        ])
      end
    end

    context "when there is metrics data" do
      let(:daily_metrics_data) do
        {
          submissions: {
            "2021-06-08" => 4.0,
            "2021-06-10" => 10.0,
          },
          starts: {
            "2021-06-08" => 12.0,
            "2021-06-10" => 20.0,
            "2021-06-12" => 5.0,
          },
        }
      end

      it "generates CSV rows with the metrics data" do
        csv = described_class.csv(form_id:, first_made_live_at:)
        rows = CSV.parse(csv)
        expect(rows).to eq([
          ["Date", "Started", "Completed", "Completion rate (%)", "Started but not completed"],
          ["14/06/2021", "0", "0", "No starts", "0"],
          ["13/06/2021", "0", "0", "No starts", "0"],
          ["12/06/2021", "5", "0", "0.0", "5"],
          ["11/06/2021", "0", "0", "No starts", "0"],
          ["10/06/2021", "20", "10", "50.0", "10"],
          ["09/06/2021", "0", "0", "No starts", "0"],
          ["08/06/2021", "12", "4", "33.3", "8"],
        ])
      end

      context "when there is a day with no starts but some submissions" do
        let(:first_made_live_at) { 1.day.ago }
        let(:daily_metrics_data) do
          {
            submissions: {
              "2021-06-14" => 4.0,
            },
            starts: {},
          }
        end

        it "generates a row with 'No starts' for the completion rate and 0 started but not completed" do
          csv = described_class.csv(form_id:, first_made_live_at:)
          rows = CSV.parse(csv)
          expect(rows).to eq([
            ["Date", "Started", "Completed", "Completion rate (%)", "Started but not completed"],
            ["14/06/2021", "0", "4", "No starts", "0"],
          ])
        end
      end

      context "when there is a day with more completions than starts" do
        let(:first_made_live_at) { 1.day.ago }
        let(:daily_metrics_data) do
          {
            submissions: {
              "2021-06-14" => 4.0,
            },
            starts: {
              "2021-06-14" => 2.0,
            },
          }
        end

        it "generates a row with a completion rate above 100%" do
          csv = described_class.csv(form_id:, first_made_live_at:)
          rows = CSV.parse(csv)
          expect(rows).to eq([
            ["Date", "Started", "Completed", "Completion rate (%)", "Started but not completed"],
            ["14/06/2021", "2", "4", "200.0", "0"],
          ])
        end
      end
    end
  end
end
