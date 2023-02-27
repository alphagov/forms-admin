require "rails_helper"

describe Forms::BaseController, type: :controller do
  subject(:base_controller) { described_class.new }

  let(:form) { build :form, id: 1 }
  let(:headers) do
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Accept" => "application/json",
    }
  end

  describe "#current_form" do
    before do
      ActiveResource::HttpMock.respond_to(false) do |mock|
        mock.get "/api/v1/forms/1", headers, form.to_json, 200
      end
    end

    it "returns the current form" do
      params = ActionController::Parameters.new(form_id: 1)
      allow(Form).to receive(:find).and_return(form)
      allow(controller).to receive(:params).and_return(params)
      expect(controller.current_form).to eq form
    end

    it "memorizes the find form request so it doesn't have to repeat the calls" do
      params = ActionController::Parameters.new(form_id: 1)
      allow(Form).to receive(:find).and_return(form)
      allow(controller).to receive(:params).and_return(params)
      controller.current_form
      controller.current_form
      expect(Form).to have_received(:find).exactly(1).times
    end
  end
end
