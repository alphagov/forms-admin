require "rails_helper"

RSpec.describe "Forms", type: :request do
  describe "Showing an existing form" do
    describe "Given a form" do
      let(:form) do
        Form.new({
          id: 2,
          name: "Form name",
          submission_email: "submission@email.com",
          privacy_policy_url: "https://example.com/privacy_policy",
          live_at: "",
        })
      end

      let(:pages) do
        [Page.new({
          id: 1,
          form_id: 2,
          question_text: "What is your work address?",
          question_short_name: "Work address",
          hint_text: "This should be the location stated in your contract.",
          answer_type: "address",
        })]
      end

      let(:headers) do
        {
          "X-API-Token" => ENV["API_KEY"],
          "Accept" => "application/json",
        }
      end

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", headers, form.to_json, 200
          mock.get "/api/v1/forms/2/pages", headers, pages.to_json, 200
        end

        get form_path(2)
      end

      it "Reads the form from the API" do
        expect(form).to have_been_read

        pages_request = ActiveResource::Request.new(:get, "/api/v1/forms/2", {}, headers)
        expect(ActiveResource::HttpMock.requests).to include pages_request
      end
    end
  end

  describe "no form found" do
    let(:headers) do
      {
        "X-API-Token" => ENV["API_KEY"],
        "Accept" => "application/json",
      }
    end

    let(:no_data_found_response) do
      {
        "error": "not_found",
      }
    end
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/999", headers, no_data_found_response, 404
      end

      get form_path(999)
    end

    it "Render the not found page" do
      expect(response.body).to include(I18n.t("not_found.title"))
    end

    it "returns 404" do
      expect(response.status).to eq(404)
    end
  end

  describe "Deleting an existing form" do
    describe "Given a valid form" do
      let(:form) do
        Form.new({
          name: "Form name",
          submission_email: "submission@email.com",
          id: 2,
          org: "test-org",
          start_page: 1,
          live_at: "",
        })
      end

      let(:req_headers) do
        {
          "X-API-Token" => ENV["API_KEY"],
          "Accept" => "application/json",
        }
      end

      let(:post_headers) do
        {
          "X-API-Token" => ENV["API_KEY"],
          "Content-Type" => "application/json",
        }
      end

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", req_headers, form.to_json, 200
        end

        get delete_form_path(form_id: 2)
      end

      it "reads the form from the API" do
        expect(form).to have_been_read
      end
    end
  end

  describe "Destroying an existing form" do
    describe "Given a valid form" do
      let(:form) do
        Form.new(
          name: "Form name",
          submission_email: "submission@email.com",
          id: 2,
        )
      end

      before do
        ActiveResourceMock.mock_resource(form,
                                         {
                                           read: { response: form, status: 200 },
                                           delete: { response: {}, status: 200 },
                                         })

        delete destroy_form_path(form_id: 2, forms_delete_confirmation_form: { confirm_deletion: "true" })
      end

      it "Redirects you to the home screen" do
        expect(response).to redirect_to(root_path)
      end

      it "Deletes the form on the API" do
        expect(form).to have_been_deleted
      end
    end
  end
end
