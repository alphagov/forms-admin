require "rails_helper"

RSpec.describe Forms::LiveController, type: :request do
  let(:headers) do
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Accept" => "application/json",
    }
  end

  let(:form) do
    build(:form, :live, id: 2)
  end

  before do
    login_as_editor_user
  end

  describe "#show_form" do
    before do
      allow(CloudWatchService).to receive(:week_submissions).and_return(501)
      allow(CloudWatchService).to receive(:week_starts).and_return(1305)

      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/2", headers, form.to_json, 200
        mock.get "/api/v1/forms/2/live", headers, form.to_json, 200
      end

      get live_form_path(2)
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read

      pages_request = ActiveResource::Request.new(:get, "/api/v1/forms/2", {}, headers)
      expect(ActiveResource::HttpMock.requests).to include pages_request
    end

    it "renders the live template and no param" do
      expect(response).to render_template("live/show_form")
    end

    context "with metrics enabled", feature_metrics_for_form_creators_enabled: true do
      context "when the form went live today" do
        it "does not read the Cloudwatch API" do
          expect(CloudWatchService).not_to have_received(:week_submissions)
          expect(CloudWatchService).not_to have_received(:week_starts)
        end
      end

      context "when the form went live before today" do
        let(:form) do
          build(:form, :live, id: 2, live_at: Time.zone.now - 1.day)
        end

        it "reads the Cloudwatch API" do
          expect(CloudWatchService).to have_received(:week_submissions).once
          expect(CloudWatchService).to have_received(:week_starts).once
        end
      end
    end

    context "when the metrics feature flag is off", feature_metrics_for_form_creators_enabled: false do
      context "when the form went live today" do
        it "does not read the Cloudwatch API" do
          expect(CloudWatchService).not_to have_received(:week_submissions)
          expect(CloudWatchService).not_to have_received(:week_starts)
        end
      end

      context "when the form went live before today" do
        let(:form) do
          build(:form, :live, id: 2, live_at: Time.zone.now - 1.day)
        end

        it "does not read the Cloudwatch API" do
          expect(CloudWatchService).not_to have_received(:week_submissions)
          expect(CloudWatchService).not_to have_received(:week_starts)
        end
      end
    end
  end

  describe "#show_pages" do
    context "with a live form" do
      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", headers, form.to_json, 200
          mock.get "/api/v1/forms/2/live", headers, form.to_json, 200
        end

        get live_form_pages_path(2)
      end

      it "renders the live template and no param" do
        expect(response).to render_template("live/show_pages")
      end
    end
  end
end
