require "rails_helper"

RSpec.describe Forms::LiveController, type: :request do
  let(:headers) do
    {
      "X-API-Token" => ENV["API_KEY"],
      "Accept" => "application/json",
    }
  end

  let(:form) do
    build(:form, :live, id: 2)
  end

  describe "#show_form" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/2", headers, form.to_json, 200
        mock.get "/api/v1/forms/2/pages", headers, form.pages.to_json, 200
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
  end

  describe "#show_pages" do
    context "with a live form" do
      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", headers, form.to_json, 200
        end

        get live_form_pages_path(2)
      end

      context "when live_view feature is enabled", feature_live_view: true do
        it "renders the live template and no param" do
          expect(response).to render_template("live/show_pages")
        end
      end
    end
  end
end
