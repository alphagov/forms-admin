require "rails_helper"

describe HeartbeatController, type: :request do
  describe "GET /ping" do
    it "returns PONG" do
      get "/ping"

      expect(response.body).to eq "PONG"
    end

    context "when service is in maintenance mode" do
      before do
        allow(Settings).to receive(:maintenance_mode_enabled).and_return(true)
      end

      it "returns PONG" do
        get "/ping"
        expect(response.body).to eq "PONG"
      end
    end
  end
end
