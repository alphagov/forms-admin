require "rails_helper"

RSpec.describe Forms::UnarchiveController, type: :request do
  let(:user) { build :editor_user }

  let(:form) do
    build(:form,
          :archived,
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

  let(:form_params) { nil }

  describe "#new" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.put "/api/v1/forms/2", post_headers
        mock.get "/api/v1/forms/2", headers, form.to_json, 200
      end

      ActiveResourceMock.mock_resource(form,
                                       {
                                         read: { response: form, status: 200 },
                                         update: { response: updated_form, status: 200 },
                                       })

      login_as user

      get unarchive_path(form_id: 2)
    end

    it "reads the form from the API" do
      expect(form).to have_been_read
    end

    it "returns 200" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the confirmation page" do
      expect(response).to render_template("unarchive_form")
    end

    context "when current user has a trial account" do
      let(:user) { build :user, :with_trial_role }

      it "is forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "#create" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.post "/api/v1/forms/2/make-live", post_headers
        mock.get "/api/v1/forms/2", headers, form.to_json, 200
        mock.get "/api/v1/forms/2/live", headers, form.to_json, 200
      end

      login_as user

      post(unarchive_create_path(form_id: 2), params: form_params)
    end

    context "when making a form live again" do
      let(:form_params) { { forms_make_live_input: { confirm: :yes, form: } } }

      it "reads the form from the API" do
        expect(form).to have_been_read
      end

      it "makes form live on the API" do
        make_live_post = ActiveResource::Request.new(:post, "/api/v1/forms/2/make-live", {}, post_headers)
        expect(ActiveResource::HttpMock.requests).to include make_live_post
      end

      it "renders the confirmation page" do
        expect(response).to render_template("forms/make_live/confirmation")
      end

      it "has the page title 'Your form is live'" do
        expect(response.body).to include "Your form is live"
      end
    end

    context "when deciding not to make a form live again" do
      let(:form_params) { { forms_make_live_input: { confirm: :no } } }

      it "reads the form from the API" do
        expect(form).to have_been_read
      end

      it "does not update the form on the API" do
        expect(form).not_to have_been_updated
      end

      it "redirects you to the archived form page" do
        expect(response).to redirect_to(archived_form_path(2))
      end
    end

    context "when no option is selected" do
      let(:form_params) { { forms_make_live_input: { confirm: :"" } } }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not update the form on the API" do
        expect(form).not_to have_been_updated
      end

      it "re-renders the page with an error" do
        expect(response).to render_template("unarchive_form")
        expect(response.body).to include("You must choose an option")
      end
    end

    context "when current user has a trial account" do
      let(:user) { build :user, :with_trial_role }

      it "is forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
