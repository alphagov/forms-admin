require "rails_helper"

RSpec.describe ErrorsController, type: :request do
  describe "Page not found" do
    before do
      get "/404"
    end

    it "returns http code 404" do
      expect(response).to have_http_status(:not_found)
    end

    it "renders the not found template" do
      expect(response.body).to include(I18n.t("not_found.title"))
    end
  end

  describe "Internal server error" do
    it "returns http code 500" do
      get "/500"
      expect(response).to have_http_status(:internal_server_error)
    end
  end

  describe "Service unavailable page" do
    it "returns http code 503" do
      allow(Settings).to receive(:service_unavailable).and_return(true)
      get "/"
      expect(response).to have_http_status(:service_unavailable)
    end
  end
end
