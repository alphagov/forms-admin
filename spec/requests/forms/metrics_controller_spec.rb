require "rails_helper"

RSpec.describe Forms::MetricsController, type: :request do
  let(:forms_env) { "test" }
  let(:form_name) { "A form name that is really long and will cause the filename to be truncated to obey the limit" }
  let(:first_made_live_at) { Time.zone.now - 2.days }
  let(:form) { create(:form, :live, name: form_name, first_made_live_at:) }
  let(:group) { create(:group, organisation: standard_user.organisation) }
  let(:cloud_watch_client) { Aws::CloudWatch::Client.new(stub_responses: true) }
  let(:current_user) { standard_user }

  around do |example|
    travel_to(Time.zone.local(2021, 6, 15, 4, 30, 0)) do
      example.run
    end
  end

  before do
    allow(Settings).to receive_messages(cloudwatch_metrics_enabled: true, forms_env: forms_env)

    allow(Aws::CloudWatch::Client).to receive(:new).and_return(cloud_watch_client)

    submitted_datapoints = [
      { timestamp: Time.zone.local(2021, 6, 13), sum: 5.0 },
      { timestamp: Time.zone.local(2021, 6, 14), sum: 9.0 },
    ]
    submitted_metric_response = cloud_watch_client.stub_data(:get_metric_statistics, datapoints: submitted_datapoints)
    allow(cloud_watch_client).to receive(:get_metric_statistics).with(cloud_watch_request("Submitted")).and_return(submitted_metric_response)

    started_datapoints = [
      { timestamp: Time.zone.local(2021, 6, 13), sum: 7.0 },
      { timestamp: Time.zone.local(2021, 6, 14), sum: 12.0 },
    ]
    started_metric_response = cloud_watch_client.stub_data(:get_metric_statistics, datapoints: started_datapoints)
    allow(cloud_watch_client).to receive(:get_metric_statistics).with(cloud_watch_request("Started")).and_return(started_metric_response)

    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as current_user
  end

  describe "#metrics_csv" do
    before do
      get metrics_csv_path(form_id: form.id)
    end

    context "when the user is authorized" do
      context "when the form is live" do
        it "responds with a CSV file" do
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to eq("text/csv; charset=iso-8859-1")
          expect(response.headers["content-disposition"])
            .to match("attachment; filename=a_form_name_that_is_really_long_and_will_cause_the_filename_to_be_truncated_to_obey_2021-06-15.csv")
        end

        it "includes the correct metrics data in the CSV" do
          rows = CSV.parse(response.body)
          expect(rows).to eq([
            ["Date", "Started", "Completed", "Completion rate (%)", "Started but not completed"],
            ["14/06/2021", "12", "9", "75.0", "3"],
            ["13/06/2021", "7", "5", "71.4", "2"],
          ])
        end
      end

      context "when the form is archived" do
        let(:form) { create(:form, :archived, name: form_name, first_made_live_at:) }

        it "responds with a CSV file" do
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to eq("text/csv; charset=iso-8859-1")
        end
      end
    end

    context "when the user is unauthorized" do
      let(:current_user) { build :user }

      it "returns a 403 forbidden response" do
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "when the form has no live or archived document" do
      let(:form) { create(:form) }

      it "returns a 404 not found response" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  def cloud_watch_request(metric_name)
    {
      metric_name:,
      namespace: "Forms",
      dimensions: [
        {
          name: "Environment",
          value: forms_env,
        },
        {
          name: "FormId",
          value: form.id.to_s,
        },
      ],
      start_time: first_made_live_at.midnight,
      end_time: Time.zone.now.midnight,
      period: 86_400,
      statistics: %w[Sum],
      unit: "Count",
    }
  end
end
