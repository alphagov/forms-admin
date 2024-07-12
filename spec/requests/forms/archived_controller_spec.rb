require "rails_helper"

RSpec.describe Forms::ArchivedController, type: :request do
  let(:form) { build(:form, :live, id:) }
  let(:id) { 2 }

  before do
    group = create :group
    create :membership, group:, user: editor_user
    GroupForm.create! group:, form_id: form.id

    login_as_editor_user

    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms/#{id}", headers, form.to_json, 200
      mock.get "/api/v1/forms/#{id}/archived", headers, form.to_json, 200
    end
  end

  describe "#show_form" do
    before do
      get archived_form_path(id)
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read

      pages_request = ActiveResource::Request.new(:get, "/api/v1/forms/#{id}", {}, headers)
      expect(ActiveResource::HttpMock.requests).to include pages_request
    end

    it "renders the show archived form template" do
      expect(response).to render_template(:show_form)
    end
  end

  describe "#show_pages" do
    before do
      get archived_form_pages_path(id)
    end

    it "renders the show archived form pages template" do
      expect(response).to render_template(:show_pages)
    end
  end
end
