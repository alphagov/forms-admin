require "rails_helper"

RSpec.describe "MakeLive controller", type: :request do
  let(:form) do
    build(:form,
          :ready_for_live,
          id: 2)
  end

  let(:updated_form) do
    build(:form,
          :live,
          id: 2,
          name: form.name,
          form_slug: form.form_slug,
          submission_email: form.submission_email,
          privacy_policy_url: form.privacy_policy_url,
          support_email: form.support_email,
          pages: form.pages)
  end

  let(:req_headers) do
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

  let(:form_params) { nil }

  describe "#new" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.put "/api/v1/forms/2", post_headers
        mock.get "/api/v1/forms/2", req_headers, form.to_json, 200
      end

      ActiveResourceMock.mock_resource(form,
                                       {
                                         read: { response: form, status: 200 },
                                         update: { response: updated_form, status: 200 },
                                       })
      get make_live_path(form_id: 2)
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end

    it "returns 200" do
      expect(response).to have_http_status(:ok)
    end

    context "when the form is being created for the first time" do
      it "renders make your form live" do
        expect(response).to render_template("make_your_form_live")
      end
    end

    context "when editing a draft of an existing live form", feature_draft_live_versioning: true do
      let(:form) do
        build(:form,
              :live,
              id: 2)
      end

      it "Reads the form from the API" do
        expect(form).to have_been_read
      end

      it "renders make your changes live" do
        expect(response).to render_template("make_your_changes_live")
      end
    end

    context "when the form is already live and the draft feature is not enabled", feature_draft_live_versioning: false do
      let(:form) do
        build(:form,
              :live,
              id: 2)
      end

      it "Reads the form from the API" do
        expect(form).to have_been_read
      end

      it "redirects to confirmation page" do
        expect(response).to redirect_to(live_confirmation_url(2))
      end
    end
  end

  describe "#confirmation" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.put "/api/v1/forms/2", post_headers
        mock.get "/api/v1/forms/2", req_headers, form.to_json, 200
      end
      get live_confirmation_url(form_id: 2)
    end

    context "when the form is already live" do
      let(:form) do
        Form.new(
          name: "Form name",
          form_slug: "form-name",
          submission_email: "submission@email.com",
          id: 2,
          org: "test-org",
          privacy_policy_url: "https://www.example.com",
          live_at: "2021-01-01T00:00:00.000Z",
          what_happens_next_text: "We usually respond to applications within 10 working days.",
        )
      end

      it "Reads the form from the API" do
        expect(form).to have_been_read
      end

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders confirmation" do
        expect(response).to render_template(:confirmation)
      end
    end

    context "when the form is not live" do
      it "Reads the form from the API" do
        expect(form).to have_been_read
      end

      it "redirects to the make_live page" do
        expect(response).to redirect_to(make_live_url(2))
      end
    end
  end

  describe "#create" do
    around do |example|
      Timecop.freeze(Time.zone.local(2021, 1, 1)) do
        example.run
      end
    end

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.post "/api/v1/forms/2/make-live", post_headers
        mock.get "/api/v1/forms/2", req_headers, form.to_json, 200
      end

      post(make_live_path(form_id: 2), params: form_params)
    end

    context "when making a form live" do
      let(:form_params) { { forms_make_live_form: { confirm_make_live: :made_live, form: } } }

      it "Reads the form from the API" do
        expect(form).to have_been_read
      end

      it "Makes form live on the API" do
        make_live_post = ActiveResource::Request.new(:post, "/api/v1/forms/2/make-live", {}, post_headers)
        expect(ActiveResource::HttpMock.requests).to include make_live_post
      end

      it "redirects you to the confirmation page" do
        expect(response).to redirect_to(live_confirmation_url(2))
      end
    end

    context "when deciding not to make a form live" do
      let(:form_params) { { forms_make_live_form: { confirm_make_live: :not_made_live } } }

      it "Reads the form from the API" do
        expect(form).to have_been_read
      end

      it "does not update the form on the API" do
        expect(form).not_to have_been_updated
      end

      it "redirects you to the form page" do
        expect(response).to redirect_to(form_path(2))
      end
    end
  end
end
