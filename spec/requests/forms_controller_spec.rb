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

      post form_pages_path(2), params: { forms_mark_complete_input: { mark_complete: "true" } }
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

        post form_pages_path(2), params: { forms_mark_complete_input: { mark_complete: nil } }
      end

      it "renders the index page" do
        expect(response).to render_template("pages/index")
      end

      it "returns 422 error code" do
        expect(response.status).to eq(422)
      end

      it "sets mark_complete to false" do
        expect(assigns[:mark_complete_input].mark_complete).to eq("false")
      end
    end
  end
end
