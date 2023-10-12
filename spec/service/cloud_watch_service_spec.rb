require "rails_helper"

describe CloudWatchService do
  let(:forms_env) { "test" }
  let(:form_id) { 3 }

  before do
    allow(Settings).to receive(:forms_env).and_return(forms_env)
  end

  around do |example|
    Timecop.freeze(Time.zone.local(2021, 1, 1, 4, 30, 0)) do
      example.run
    end
  end

  describe "#week_submissions" do
    let(:datapoints) { [{ sum: total_submissions }] }
    let(:total_submissions) { 3.0 }

    it "calls the cloudwatch client with get_metric_statistics" do
      cloudwatch_client = Aws::CloudWatch::Client.new(stub_responses: true)
      metric_response = cloudwatch_client.stub_data(:get_metric_statistics, datapoints:)

      allow(Aws::CloudWatch::Client).to receive(:new).and_return(cloudwatch_client)

      allow(cloudwatch_client).to receive(:get_metric_statistics).with({
        metric_name: "submitted",
        namespace: "forms/#{forms_env}",
        dimensions: [
          {
            name: "form_id",
            value: form_id.to_s,
          },
        ],
        start_time: Time.zone.now.midnight - 7.days,
        end_time: Time.zone.now.midnight,
        period: 604_800,
        statistics: %w[Sum],
        unit: "Count",
      }).and_return(metric_response)

      expect(cloudwatch_client).to receive(:get_metric_statistics).with({
        metric_name: "submitted",
        namespace: "forms/#{forms_env}",
        dimensions: [
          {
            name: "form_id",
            value: form_id.to_s,
          },
        ],
        start_time: Time.zone.now.midnight - 7.days,
        end_time: Time.zone.now.midnight,
        period: 604_800,
        statistics: %w[Sum],
        unit: "Count",
      }).once

      described_class.week_submissions(form_id:)
    end

    it "returns the sum for the datapoint in the response" do
      cloudwatch_client = Aws::CloudWatch::Client.new(stub_responses: true)
      metric_response = cloudwatch_client.stub_data(:get_metric_statistics, datapoints:)
      cloudwatch_client.stub_responses(:get_metric_statistics, metric_response)

      allow(Aws::CloudWatch::Client).to receive(:new).and_return(cloudwatch_client)

      expect(described_class.week_submissions(form_id:)).to eq(total_submissions)
    end

    context "when there is no submission data for the form" do
      let(:datapoints) { [] }

      it "returns 0 if there is no data for the form" do
        cloudwatch_client = Aws::CloudWatch::Client.new(stub_responses: true)
        metric_response = cloudwatch_client.stub_data(:get_metric_statistics, datapoints:)
        cloudwatch_client.stub_responses(:get_metric_statistics, metric_response)

        allow(Aws::CloudWatch::Client).to receive(:new).and_return(cloudwatch_client)

        expect(described_class.week_submissions(form_id:)).to eq(0)
      end
    end
  end

  describe "#week_starts" do
    let(:datapoints) { [{ sum: total_starts }] }
    let(:total_starts) { 5.0 }

    it "calls the cloudwatch client with get_metric_statistics" do
      cloudwatch_client = Aws::CloudWatch::Client.new(stub_responses: true)
      metric_response = cloudwatch_client.stub_data(:get_metric_statistics, datapoints:)

      allow(Aws::CloudWatch::Client).to receive(:new).and_return(cloudwatch_client)

      allow(cloudwatch_client).to receive(:get_metric_statistics).with({
        metric_name: "started",
        namespace: "forms/#{forms_env}",
        dimensions: [
          {
            name: "form_id",
            value: form_id.to_s,
          },
        ],
        start_time: Time.zone.now.midnight - 7.days,
        end_time: Time.zone.now.midnight,
        period: 604_800,
        statistics: %w[Sum],
        unit: "Count",
      }).and_return(metric_response)

      expect(cloudwatch_client).to receive(:get_metric_statistics).with({
        metric_name: "started",
        namespace: "forms/#{forms_env}",
        dimensions: [
          {
            name: "form_id",
            value: form_id.to_s,
          },
        ],
        start_time: Time.zone.now.midnight - 7.days,
        end_time: Time.zone.now.midnight,
        period: 604_800,
        statistics: %w[Sum],
        unit: "Count",
      }).once

      described_class.week_starts(form_id:)
    end

    it "returns the sum for the datapoint in the response" do
      cloudwatch_client = Aws::CloudWatch::Client.new(stub_responses: true)
      metric_response = cloudwatch_client.stub_data(:get_metric_statistics, datapoints:)
      cloudwatch_client.stub_responses(:get_metric_statistics, metric_response)

      allow(Aws::CloudWatch::Client).to receive(:new).and_return(cloudwatch_client)

      expect(described_class.week_starts(form_id:)).to eq(total_starts)
    end

    context "when there is no submission data for the form" do
      let(:datapoints) { [] }

      it "returns 0 if there is no data for the form" do
        cloudwatch_client = Aws::CloudWatch::Client.new(stub_responses: true)
        metric_response = cloudwatch_client.stub_data(:get_metric_statistics, datapoints:)
        cloudwatch_client.stub_responses(:get_metric_statistics, metric_response)

        allow(Aws::CloudWatch::Client).to receive(:new).and_return(cloudwatch_client)

        expect(described_class.week_starts(form_id:)).to eq(0)
      end
    end
  end
end
