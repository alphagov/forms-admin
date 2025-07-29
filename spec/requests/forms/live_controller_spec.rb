require "rails_helper"

RSpec.describe Forms::LiveController, type: :request do
  let(:form) { build(:form, :live, id: 2) }
  let(:made_live_form) { build(:made_live_form, id: 2, live_at: Time.zone.now - 2.days) }
  let(:forms_env) { "test" }
  let(:cloud_watch_client) { Aws::CloudWatch::Client.new(stub_responses: true) }

  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as_standard_user
  end

  describe "#show_form" do
    before do
      allow(Settings).to receive(:forms_env).and_return(forms_env)

      allow(Aws::CloudWatch::Client).to receive(:new).and_return(cloud_watch_client)

      submitted_metric_response = cloud_watch_client.stub_data(:get_metric_statistics, datapoints: [{ sum: 501.0 }])
      allow(cloud_watch_client).to receive(:get_metric_statistics).with(cloud_watch_request("Submitted")).and_return(submitted_metric_response)

      started_metric_response = cloud_watch_client.stub_data(:get_metric_statistics, datapoints: [{ sum: 1306.0 }])
      allow(cloud_watch_client).to receive(:get_metric_statistics).with(cloud_watch_request("Started")).and_return(started_metric_response)

      allow(FormRepository).to receive_messages(find: form, find_live: made_live_form)

      get live_form_path(2)
    end

    it "Reads the form" do
      expect(FormRepository).to have_received(:find)
      expect(FormRepository).to have_received(:find_live)
    end

    it "renders the live template" do
      expect(response).to render_template(:show_form)
    end

    it "displays the completion rate metric" do
      page = Capybara.string(response.body)
      expect(page.find_all(".app-metrics__big-number-number")[0]).to have_text "38%"
    end

    it "displays the form submitted metric" do
      page = Capybara.string(response.body)
      expect(page.find_all(".app-metrics__big-number-number")[1]).to have_text "501"
    end

    it "displays the form started but not submitted metric" do
      page = Capybara.string(response.body)
      expect(page.find_all(".app-metrics__big-number-number")[2]).to have_text "805"
    end
  end

  describe "#show_pages" do
    context "with a live form" do
      before do
        allow(FormRepository).to receive_messages(find: form, find_live: made_live_form)

        get live_form_pages_path(2)
      end

      it "renders the live template" do
        expect(response).to render_template(:show_pages)
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
      start_time: Time.zone.now.midnight - 7.days,
      end_time: Time.zone.now.midnight,
      period: 604_800,
      statistics: %w[Sum],
      unit: "Count",
    }
  end
end
