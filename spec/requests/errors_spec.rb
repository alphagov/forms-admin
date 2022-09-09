require "rails_helper"

RSpec.describe "Errors", type: :request do
  describe "Page not found" do
    it "returns http code 404" do
      get "/404"
      expect(response).to have_http_status(:not_found)
    end

    describe "random non-exist path" do
      it "returns http code 404" do
        get "/random/string/"
        expect(response).to have_http_status(:not_found)
      end

      it "renders the not found template" do
        get "/random/string/"
        expect(response.body).to include(I18n.t("not_found.title"))
      end
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
      stub_const "ENV", ENV.to_h.merge("SERVICE_UNAVAILABLE" => "true")
      get "/"
      expect(response).to have_http_status(:service_unavailable)
    end
  end
end
