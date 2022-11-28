require "rails_helper"

RSpec.describe "TypeOfAnswer controller", type: :request do
  let(:form) { build :form, id: 1 }
  let(:pages){ build_list :page, 5, form_id: form.id }

  let(:subject) { build :type_of_answer_form, form: }

  let(:req_headers) do
    {
      "X-API-Token" => ENV["API_KEY"],
      "Accept" => "application/json"
    }
  end

  describe "#new" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
      end

      get type_of_answer_new_path(form_id: subject.form.id)
    end

    it "reads the existing form" do
      expect(form).to have_been_read
    end

    it "sets an instance variable for type_of_answer_path" do
      path = assigns(:type_of_answer_path)
      expect(path).to eq type_of_answer_new_path(subject.form.id)
    end

    it "renders the new template" do
      expect(response).to have_rendered("pages/type-of-answer")
    end
  end

  describe "#create" do
    describe "when form is valid and ready to store" do
      it "saves the answer type to session" do; end
      xit "redirects the user to the question details page " do; end
    end

    xit "renders the type of answer view if there are errors" do; end
  end

  describe "#edit" do
    let(:page) { build :page, id: 2, form_id: form.id }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/2", req_headers, page.to_json, 200
      end

      get type_of_answer_edit_path(form_id: page.form_id, page_id: page.id)
    end

    it "reads the existing form" do
      expect(form).to have_been_read
    end

    it "reads the existing page" do
      expect(page).to have_been_read
    end

    it "sets an instance variable for type_of_answer_path" do
      path = assigns(:type_of_answer_path)
      expect(path).to eq type_of_answer_edit_path(subject.form.id)
    end

    it "renders the new template" do
      expect(response).to have_rendered("pages/type-of-answer")
    end
  end

  describe "#update" do
    describe "when form is valid and ready to update in the DB" do
      xit "saves the updated answer type to DB" do; end
      xit "redirects the user to the question details page " do; end
    end

    xit "renders the type of answer view if there are errors" do; end
  end
end
