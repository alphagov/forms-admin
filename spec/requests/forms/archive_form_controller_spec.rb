require "rails_helper"

RSpec.describe Forms::ArchiveFormController, type: :request do
  let(:id) { 2 }
  let(:form) { build(:form, :live, id:) }

  before do
    login_as_editor_user
  end

  describe "#archive" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/#{id}", headers, form.to_json, 200
      end

      get archive_form_path(id)
    end

    it "reads the form from the APi" do
      expect(form).to have_been_read
    end

    it "returns 200" do
      expect(response).to have_http_status(:ok)
    end

    it "renders archive this form page" do
      expect(response).to render_template(:archive)
    end

    context "when form is not live" do
      let(:form) { build(:form, :archived, id:) }

      it "redirects to archived form page" do
        expect(response).to redirect_to(archived_form_path(id))
      end
    end
  end

  describe "#update" do
    let(:confirm) { :yes }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/#{id}", headers, form.to_json, 200
        mock.post "/api/v1/forms/#{id}/archive", post_headers
      end

      post archive_form_update_path(id), params: { forms_confirm_archive_form: { confirm:, form: } }
    end

    context "when 'Yes' is selected" do
      it "archives the form" do
        archive_post = ActiveResource::Request.new(:post, "/api/v1/forms/#{id}/archive", {}, post_headers)
        expect(ActiveResource::HttpMock.requests).to include archive_post
      end

      it "redirects to the success page" do
        expect(response).to redirect_to(archive_form_confirmation_path(id))
      end
    end

    context "when 'No' is selected" do
      let(:confirm) { :no }

      it "redirects to live form page" do
        expect(response).to redirect_to(live_form_path(id))
      end
    end

    context "when no option is selected" do
      let(:confirm) { nil }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "re-renders the archive this form page with an error" do
        expect(response).to render_template(:archive)
        expect(response.body).to include("Select yes if you want to archive this form")
      end
    end

    context "when form is not live" do
      let(:form) { build(:form, :archived, id:) }

      it "doesn't archive the form" do
        archive_post = ActiveResource::Request.new(:post, "/api/v1/forms/#{id}/archive", {}, post_headers)
        expect(ActiveResource::HttpMock.requests).not_to include archive_post
      end

      it "redirects to archived form page" do
        expect(response).to redirect_to(archived_form_path(id))
      end
    end
  end

  describe "#confirmation" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/#{id}", headers, form.to_json, 200
      end

      get archive_form_confirmation_path(id)
    end

    it "renders the success template" do
      expect(response).to render_template(:confirmation)
    end
  end
end
