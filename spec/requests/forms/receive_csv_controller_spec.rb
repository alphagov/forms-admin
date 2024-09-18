require "rails_helper"

RSpec.describe Forms::ReceiveCsvController, type: :request do
  let(:form) do
    build(:form, :live, id: 2, submission_type: "email")
  end

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms/2", headers, form.to_json, 200
    end

    login_as_standard_user
  end

  describe "#new" do
    before do
      get receive_csv_path(form_id: 2)
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end
  end

  describe "#create" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/2", headers, form.to_json, 200
        mock.put "/api/v1/forms/2", post_headers
      end

      post receive_csv_path(form_id: 2)
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end
  end
end
