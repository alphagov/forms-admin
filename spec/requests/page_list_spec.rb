require "rails_helper"

RSpec.describe "Page list", type: :request do
  let(:headers) do
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

  describe "Showing an existing form's pages" do
    describe "Given a form" do
      let(:pages) do
        build(:page, page_id: 99)
      end
      let(:form) do
        build(:form, id: 2, pages:)
      end

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", headers, form.to_json, 200
          mock.get "/api/v1/forms/2/pages", headers, pages.to_json, 200
        end

        get form_pages_path(2)
      end

      it "Reads the form from the API" do
        expect(form).to have_been_read

        pages_request = ActiveResource::Request.new(:get, "/api/v1/forms/2", {}, headers)
        expect(ActiveResource::HttpMock.requests).to include pages_request
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

        get form_pages_path(2)
      end

      it "Renders the forbidden page" do
        expect(response).to render_template("errors/forbidden")
      end

      it "Returns a 403 status" do
        expect(response.status).to eq(403)
      end
    end
  end

  describe "Marking the 'add pages' task as complete" do
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
  end
end
