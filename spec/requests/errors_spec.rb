require "rails_helper"

RSpec.describe "Errors", type: :request do
  describe "Page not found" do
    it "returns http code 404" do
      get "/404"
      expect(response).to have_http_status(404)
    end
  end

  describe "Internal server error" do
    it "returns http code 500" do
      get "/500"
      expect(response).to have_http_status(500)
    end
  end

  describe "Service unavailable page" do
    it "returns http code 503" do
      stub_const 'ENV', ENV.to_h.merge('SERVICE_UNAVAILABLE' => 'true')
      get "/"
      expect(response).to have_http_status(503)
    end
  end
end
