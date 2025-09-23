require "rails_helper"

RSpec.describe Forms::LiveController, type: :request do
  let(:form) { create(:form, :live) }
  let(:forms_env) { "test" }
  let(:cloud_watch_client) { Aws::CloudWatch::Client.new(stub_responses: true) }

  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    # make the form live 2 days in the past so that metrics are displayed
    travel_to Time.zone.now - 2.days do
      form
    end

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

      get live_form_path(form.id)
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

    context "when the form is live with draft" do
      let(:form) { create(:form, :live_with_draft) }

      it "renders the live template" do
        expect(response).to render_template(:show_form)
      end
    end

    context "when the form is archived" do
      let(:form) { create(:form, :archived) }

      it "redirects to the archived form page" do
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(archived_form_path(form))
      end
    end

    context "when the form is draft" do
      let(:form) { create(:form) }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "#show_pages" do
    before do
      get live_form_pages_path(form.id)
    end

    context "with a live form" do
      it "renders the live template" do
        expect(response).to render_template(:show_pages)
      end
    end

    context "when the form is live_with_draft" do
      let(:form) { create(:form, :live_with_draft) }

      it "renders the live template" do
        expect(response).to render_template(:show_pages)
      end
    end

    context "when the form is archived" do
      let(:form) { create(:form, :archived) }

      it "redirects to the archived form page" do
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(archived_form_pages_path(form))
      end
    end

    context "when the form is draft" do
      let(:form) { create(:form) }

      it "returns 404" do
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
      start_time: Time.zone.now.midnight - 7.days,
      end_time: Time.zone.now.midnight,
      period: 604_800,
      statistics: %w[Sum],
      unit: "Count",
    }
  end
end
