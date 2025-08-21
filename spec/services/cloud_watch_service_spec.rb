require "rails_helper"

describe CloudWatchService do
  subject(:cloud_watch_service) { described_class.new(form_id, made_live_date) }

  let(:forms_env) { "test" }
  let(:form_id) { 3 }
  let(:made_live_date) { live_at.to_date }
  let(:live_at) { Time.zone.now - 1.day }

  let(:cloud_watch_client) { Aws::CloudWatch::Client.new(stub_responses: true) }

  let(:submitted_datapoints) { [{ sum: total_submissions }] }
  let(:total_submissions) { 3.0 }

  let(:started_datapoints) { [{ sum: total_starts }] }
  let(:total_starts) { 5.0 }

  around do |example|
    travel_to(Time.zone.local(2021, 1, 1, 4, 30, 0)) do
      example.run
    end
  end

  before do
    allow(Settings).to receive(:forms_env).and_return(forms_env)

    allow(Aws::CloudWatch::Client).to receive(:new).and_return(cloud_watch_client)

    submitted_metric_response = cloud_watch_client.stub_data(:get_metric_statistics, datapoints: submitted_datapoints)
    allow(cloud_watch_client).to receive(:get_metric_statistics).with({
      metric_name: "Submitted",
      namespace: "Forms",
      dimensions: [
        {
          name: "Environment",
          value: forms_env,
        },
        {
          name: "FormId",
          value: form_id.to_s,
        },
      ],
      start_time: Time.zone.now.midnight - 7.days,
      end_time: Time.zone.now.midnight,
      period: 604_800,
      statistics: %w[Sum],
      unit: "Count",
    }).and_return(submitted_metric_response)

    started_metric_response = cloud_watch_client.stub_data(:get_metric_statistics, datapoints: started_datapoints)
    allow(cloud_watch_client).to receive(:get_metric_statistics).with({
      metric_name: "Started",
      namespace: "Forms",
      dimensions: [
        {
          name: "Environment",
          value: forms_env,
        },
        {
          name: "FormId",
          value: form_id.to_s,
        },
      ],
      start_time: Time.zone.now.midnight - 7.days,
      end_time: Time.zone.now.midnight,
      period: 604_800,
      statistics: %w[Sum],
      unit: "Count",
    }).and_return(started_metric_response)
  end

  context "when CloudWatch returns metrics" do
    it "calls the CloudWatch client to get the submitted metrics" do
      expect(cloud_watch_client).to receive(:get_metric_statistics).with({
        metric_name: "Submitted",
        namespace: "Forms",
        dimensions: [
          {
            name: "Environment",
            value: forms_env,
          },
          {
            name: "FormId",
            value: form_id.to_s,
          },
        ],
        start_time: Time.zone.now.midnight - 7.days,
        end_time: Time.zone.now.midnight,
        period: 604_800,
        statistics: %w[Sum],
        unit: "Count",
      }).once

      cloud_watch_service.metrics_data
    end

    it "returns the week submissions total" do
      expect(cloud_watch_service.metrics_data[:weekly_submissions]).to eq(total_submissions)
    end

    it "calls the CloudWatch client to get the started metrics" do
      expect(cloud_watch_client).to receive(:get_metric_statistics).with({
        metric_name: "Started",
        namespace: "Forms",
        dimensions: [
          {
            name: "Environment",
            value: forms_env,
          },
          {
            name: "FormId",
            value: form_id.to_s,
          },
        ],
        start_time: Time.zone.now.midnight - 7.days,
        end_time: Time.zone.now.midnight,
        period: 604_800,
        statistics: %w[Sum],
        unit: "Count",
      }).once

      cloud_watch_service.metrics_data
    end

    it "returns the week starts total" do
      expect(cloud_watch_service.metrics_data[:weekly_starts]).to eq(total_starts)
    end
  end

  context "when there is no data for the submitted metric" do
    let(:submitted_datapoints) { [] }

    it "returns 0 for the weekly submissions total" do
      expect(cloud_watch_service.metrics_data[:weekly_submissions]).to eq(0)
    end
  end

  context "when there is no data for the started metric" do
    let(:started_datapoints) { [] }

    it "returns 0 for the weekly starts total" do
      expect(cloud_watch_service.metrics_data[:weekly_starts]).to eq(0)
    end
  end

  context "when the form was made today" do
    let(:live_at) { Time.zone.now }

    it "returns 0 weekly submissions" do
      expect(cloud_watch_service.metrics_data).to eq({ weekly_submissions: 0, weekly_starts: 0 })
    end

    it "does not call CloudWatch" do
      cloud_watch_service.metrics_data
      expect(cloud_watch_client).not_to have_received(:get_metric_statistics)
    end
  end

  context "when AWS credentials have not been configured" do
    before do
      allow(Sentry).to receive(:capture_exception)
      allow(cloud_watch_client).to receive(:get_metric_statistics).and_raise(Aws::Errors::MissingCredentialsError)
    end

    it "returns nil and logs the exception in Sentry" do
      expect(cloud_watch_service.metrics_data).to be_nil
      expect(Sentry).to have_received(:capture_exception).once
    end
  end

  context "when CloudWatch returns an error" do
    before do
      allow(Sentry).to receive(:capture_exception)
      allow(cloud_watch_client)
        .to receive(:get_metric_statistics)
        .and_raise(Aws::CloudWatch::Errors::ServiceError.new(nil, "CloudWatch error", nil))
    end

    it "returns nil and logs the exception in Sentry" do
      expect(cloud_watch_service.metrics_data).to be_nil
      expect(Sentry).to have_received(:capture_exception).once
    end
  end

  context "when the made_live_date is nil" do
    let(:made_live_date) { nil }

    it "returns nil" do
      expect(cloud_watch_service.metrics_data).to be_nil
    end
  end
end
