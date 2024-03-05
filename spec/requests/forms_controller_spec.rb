require "rails_helper"

RSpec.describe FormsController, type: :request do
  let(:form) { build(:form, :with_active_resource, id: 2) }

  before do
    login_as_editor_user
  end

  describe "Showing an existing form" do
    describe "Given a live form" do
      let(:form) { build(:form, :live, :with_active_resource, id: 2) }
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

      it "includes a task list" do
        expect(assigns[:task_list]).to be_truthy
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
        create :organisation, id: 111, slug: "another-org"
        build :form, organisation_id: 111, id: 2
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

    context "with a user with no organisation" do
      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", headers, form.to_json, 200
          mock.get "/api/v1/forms/2/pages", headers, form.pages.to_json, 200
        end

        login_as build(:editor_user, :with_no_org)

        get form_path(2)
      end

      after do
        logout
      end

      it "returns 403 Forbidden" do
        expect(response).to have_http_status(:forbidden)
      end

      it "renders organisation missing page" do
        expect(response).to render_template("errors/user_missing_organisation_error")
      end
    end

    context "with a user with a trial account" do
      let(:user) { build(:user, :with_trial_role, id: 123) }
      let(:form) { build(:form, :ready_for_live, :with_active_resource, id: 2, creator_id: user.id) }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", headers, form.to_json, 200
          mock.get "/api/v1/forms/2/pages", headers, form.pages.to_json, 200
        end

        login_as user

        get form_path(2)
      end

      it "does not include setting the submission email address" do
        expect(response.body).not_to include(submission_email_form_path(2))
        expect(response.body).not_to include(submission_email_code_path(2))
      end

      it "does not include making a form live" do
        expect(response.body).not_to include(make_live_path(2))
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
        organisation_id: 1,
        creator_id: nil,
        state: :draft,
      },
       {
         id: 3,
         name: "Another form",
         form_slug: "another-form",
         submission_email: "submission@email.com",
         live_at: nil,
         has_draft_version: true,
         has_live_version: false,
         organisation_id: 1,
         creator_id: nil,
         state: :draft,
       }]
    end

    it "Reads the forms from the API" do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms?organisation_id=1", headers, forms_response.to_json, 200
      end
      get root_path

      forms_request = ActiveResource::Request.new(:get, "/api/v1/forms?organisation_id=1", {}, headers)
      expect(ActiveResource::HttpMock.requests).to include forms_request
    end

    context "with a user with no organisation" do
      before do
        ActiveResource::HttpMock.reset! # not expecting any API calls

        login_as build(:editor_user, :with_no_org)

        get root_path
      end

      it "returns 403 Forbidden" do
        expect(response).to have_http_status(:forbidden)
      end

      it "renders organisation missing page" do
        expect(response).to render_template("errors/user_missing_organisation_error")
      end

      it "does not make a call to the API" do
        expect(ActiveResource::HttpMock.requests).to be_empty
      end
    end

    context "with a user with a super_admin account" do
      context "without an orgnisation query" do
        before do
          ActiveResource::HttpMock.respond_to do |mock|
            mock.get "/api/v1/forms?organisation_id=#{super_admin_user.organisation.id}", headers, forms_response.to_json, 200
          end

          login_as_super_admin_user
          get root_path
        end

        it "returns 200 OK" do
          expect(response).to have_http_status(:ok)
        end

        it "renders the index page" do
          expect(response).to render_template("forms/index")
        end

        it "makes a call to the API" do
          forms_request = ActiveResource::Request.new(:get, "/api/v1/forms?organisation_id=#{super_admin_user.organisation.id}", {}, headers)
          expect(ActiveResource::HttpMock.requests).to include forms_request
        end
      end

      context "with a search query" do
        let(:organisation) { create(:organisation, slug: "not_super_admins_org") }

        before do
          ActiveResource::HttpMock.respond_to do |mock|
            mock.get "/api/v1/forms?organisation_id=#{organisation.id}", headers, forms_response.to_json, 200
          end

          login_as_super_admin_user
          get root_path, params: { search: { organisation_id: organisation.id } }
        end

        it "makes a call to the API with the search query" do
          forms_request = ActiveResource::Request.new(:get, "/api/v1/forms?organisation_id=#{organisation.id}", {}, headers)
          expect(ActiveResource::HttpMock.requests).to include forms_request
        end
      end
    end

    context "with a non-super_admin user organisation_id param" do
      let(:organisation) { create(:organisation, slug: "not_users_org") }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms?organisation_id=#{editor_user.organisation.id}", headers, forms_response.to_json, 200
        end

        login_as_editor_user
        get root_path, params: { organisation_id: organisation.id }
      end

      it "makes a call to the API without the search query" do
        forms_request = ActiveResource::Request.new(:get, "/api/v1/forms?organisation_id=#{editor_user.organisation.id}", {}, headers)
        expect(ActiveResource::HttpMock.requests).to include forms_request
      end
    end
  end

  describe "#mark_pages_section_completed" do
    let(:pages) do
      [build(:page, page_id: 99)]
    end

    let(:form) do
      build(:form, id: 2, pages:, question_section_completed: "false")
    end

    let(:updated_form) do
      new_form = form
      new_form.question_section_completed = "true"
      new_form
    end

    let(:user) do
      editor_user
    end

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/2", headers, form.to_json, 200
        mock.get "/api/v1/forms/2/pages", headers, pages.to_json, 200
        mock.put "/api/v1/forms/2", post_headers
      end

      login_as user

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
          mock.get "/api/v1/forms?organisation_id=1", headers, [form].to_json, 200
          mock.get "/api/v1/forms/2", headers, form.to_json, 200
          mock.get "/api/v1/forms/2/pages", headers, pages.to_json, 200
          mock.put "/api/v1/forms/2", post_headers
        end

        post form_pages_path(2), params: { forms_mark_complete_form: { mark_complete: nil } }
      end

      it "renders the index page" do
        expect(response).to render_template("pages/index")
      end

      it "returns 422 error code" do
        expect(response.status).to eq(422)
      end

      it "sets mark_complete to false" do
        expect(assigns[:mark_complete_form].mark_complete).to eq("false")
      end
    end

    context "with a user with no organisation" do
      let(:user) do
        build :editor_user, :with_no_org
      end

      it "returns 403 Forbidden" do
        expect(response).to have_http_status(:forbidden)
      end

      it "renders organisation missing page" do
        expect(response).to render_template("errors/user_missing_organisation_error")
      end

      it "does not update the form on the API" do
        expect(updated_form).not_to have_been_updated
      end
    end
  end
end
