require "rails_helper"

RSpec.describe ErrorsController, type: :request do
  describe "Not found" do
    before do
      get "/404", headers: { ACCEPT: "application/json" }
    end

    it "returns http code 404" do
      expect(response).to have_http_status(:not_found)
    end

    it "returns a JSON response" do
      expect(response.headers["Content-Type"]).to eq("application/json; charset=utf-8")
    end
  end

  describe "Internal server error" do
    before do
      get "/500", headers: { ACCEPT: "application/json" }
    end

    it "returns http code 500" do
      expect(response).to have_http_status(:internal_server_error)
    end

    it "returns a JSON response" do
      expect(response.headers["Content-Type"]).to eq("application/json; charset=utf-8")
    end
  end
end
