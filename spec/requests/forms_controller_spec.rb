require "rails_helper"

RSpec.describe FormsController, type: :request do
  let(:headers) do
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Accept" => "application/json",
    }
  end

  let(:post_headers) do
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Content-Type" => "application/json",
    }
  end

  let(:form) { build(:form, id: 2) }

  describe "Showing an existing form" do
    describe "Given a live form" do
      let(:form) { build(:form, :live, id: 2) }
      let(:params) { {} }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", headers, form.to_json, 200
          mock.get "/api/v1/forms/2/pages", headers, form.pages.to_json, 200
        end

        get form_path(2, params)
      end

      it "Reads the form from the API" do
        expect(form).to have_been_read

        pages_request = ActiveResource::Request.new(:get, "/api/v1/forms/2", {}, headers)
        expect(ActiveResource::HttpMock.requests).to include pages_request
      end

      it "renders the show template" do
        expect(response).to render_template("forms/show")
      end
    end

    context "with a non-live form" do
      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", headers, form.to_json, 200
          mock.get "/api/v1/forms/2/pages", headers, form.pages.to_json, 200
        end

        get form_path(2)
      end

      it "renders the show template" do
        expect(response).to render_template("forms/show")
      end
    end

    context "with a form from another organisation" do
      let(:form) do
        build :form, org: "another-org", id: 2
      end

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", headers, form.to_json, 200
        end

        get form_path(2)
      end

      it "Renders the forbidden page" do
        expect(response).to render_template("errors/forbidden")
      end

      it "Returns a 403 status" do
        expect(response.status).to eq(403)
      end
    end
  end

  describe "no form found" do
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
      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", headers, form.to_json, 200
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
      before do
        ActiveResourceMock.mock_resource(form,
                                         {
                                           read: { response: form, status: 200 },
                                           delete: { response: {}, status: 200 },
                                         })
        allow(Pundit).to receive(:authorize).and_return(true)
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

  describe "#index" do
    let(:forms_response) do
      [{
        id: 2,
        name: "Form",
        form_slug: "form",
        submission_email: "submission@email.com",
        live_at: nil,
        has_draft_version: true,
        has_live_version: false,
        org: "test-org",
      },
       {
         id: 3,
         name: "Another form",
         form_slug: "another-form",
         submission_email: "submission@email.com",
         live_at: nil,
         has_draft_version: true,
         has_live_version: false,
         org: "test-org",
       }]
    end

    it "Reads the forms from the API" do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms?org=test-org", headers, forms_response.to_json, 200
      end
      get root_path

      forms_request = ActiveResource::Request.new(:get, "/api/v1/forms?org=test-org", {}, headers)
      expect(ActiveResource::HttpMock.requests).to include forms_request
    end

    context "when the user does not hve a valid organisation set" do
      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms?org=", headers, forms_response.to_json, 200
        end

        login_as build(:user, organisation_slug: nil)

        get root_path
      end

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders correct page" do
        expect(response).to render_template("errors/user_missing_organisation_error")
      end

      it "does not make a call to the API" do
        expect(ActiveResource::HttpMock.requests).to be_empty
      end
    end
  end

  describe "#mark_pages_section_completed" do
    let(:pages) do
      build(:page, page_id: 99)
    end

    let(:form) do
      build(:form, id: 2, pages:, question_section_completed: "false")
    end

    let(:updated_form) do
      new_form = form
      new_form.question_section_completed = "true"
      new_form
    end

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/2", headers, form.to_json, 200
        mock.get "/api/v1/forms/2/pages", headers, pages.to_json, 200
        mock.put "/api/v1/forms/2", post_headers
      end

      post form_pages_path(2), params: { forms_mark_complete_form: { mark_complete: "true" } }
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end

    it "Updates the form on the API" do
      expect(updated_form).to have_been_updated
    end

    it "Redirects you to the form overview page" do
      expect(response).to redirect_to(form_path(2))
    end

    context "when the mark completed form is invalid" do
      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", headers, form.to_json, 200
          mock.get "/api/v1/forms/2/pages", headers, pages.to_json, 200
          mock.put "/api/v1/forms/2", post_headers
        end

        post form_pages_path(2), params: { forms_mark_complete_form: { mark_complete: nil } }
      end

      it "renders the index page" do
        expect(response).to render_template("pages/index")
      end

      it "returns 300 error code" do
        expect(response.status).to eq(422)
      end

      it "sets a flash message" do
        expect(flash[:message]).to eq "Save unsuccessful"
      end
    end
  end
end
