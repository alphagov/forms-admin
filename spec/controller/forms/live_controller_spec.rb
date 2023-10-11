require "rails_helper"

describe Forms::LiveController, type: :controller do
  let(:live_controller) { described_class.new }

  let(:form) do
    build(:form, :live, id: 2)
  end

  let(:headers) do
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Accept" => "application/json",
    }
  end

  describe "#metrics_data" do
    before do
      allow(live_controller).to receive(:current_live_form).and_return(form)
      ActiveResource::HttpMock.respond_to(false) do |mock|
        mock.get "/api/v1/forms/2", headers, form.to_json, 200
      end
    end

    context "when the form was made today" do
      it "returns form_is_new: true and 0 weekly submissions" do
        expect(live_controller.metrics_data).to eq({ weekly_submissions: 0, form_is_new: true })
      end
    end

    context "when the form was made before today" do
      let(:form) do
        build(:form, :live, id: 2, live_at: Time.zone.now - 1.day)
      end

      before do
        allow(CloudWatchService).to receive(:week_submissions).and_return(1255)
      end

      it "returns form_is_new: true and the correct number of weekly submissions" do
        expect(live_controller.metrics_data).to eq({ weekly_submissions: 1255, form_is_new: false })
      end
    end
  end
end
