require "rails_helper"

RSpec.describe Pages::TypeOfAnswerController, type: :request do
  let(:form) { build :form, id: 1 }
  let(:pages) { build_list :page, 5, form_id: form.id }

  let(:type_of_answer_form) { build :type_of_answer_form, form: }

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

  describe "#new" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
      end

      get type_of_answer_new_path(form_id: type_of_answer_form.form.id)
    end

    it "reads the existing form" do
      expect(form).to have_been_read
    end

    it "sets an instance variable for type_of_answer_path" do
      path = assigns(:type_of_answer_path)
      expect(path).to eq type_of_answer_new_path(type_of_answer_form.form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/type-of-answer")
    end
  end

  describe "#create" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
      end
    end

    context "when form is valid and ready to store" do
      before do
        post type_of_answer_create_path form_id: form.id, params: { forms_type_of_answer_form: { answer_type: type_of_answer_form.answer_type } }
      end

      context "when answer type is not selection" do
        let(:type_of_answer_form) { build :type_of_answer_form, :with_simple_answer_type, form: }

        it "saves the answer type to session" do
          expect(session[:page]).to eq({ answer_type: type_of_answer_form.answer_type, answer_settings: nil })
        end

        it "redirects the user to the question details page" do
          expect(response).to redirect_to new_page_path(form.id)
        end
      end

      context "when answer type is selection" do
        let(:type_of_answer_form) { build :type_of_answer_form, answer_type: "selection", form: }

        before do
          post type_of_answer_create_path form_id: form.id, params: { forms_type_of_answer_form: { answer_type: type_of_answer_form.answer_type } }
        end

        it "saves the answer type to session" do
          expect(session[:page]).to eq({ answer_type: type_of_answer_form.answer_type, answer_settings: nil })
        end

        it "redirects the user to the selection settings page" do
          expect(response).to redirect_to selections_settings_new_path(form.id)
        end
      end

      context "when answer type is text" do
        let(:type_of_answer_form) { build :type_of_answer_form, answer_type: "text", form: }

        before do
          post type_of_answer_create_path form_id: form.id, params: { forms_type_of_answer_form: { answer_type: type_of_answer_form.answer_type } }
        end

        it "saves the answer type to session" do
          expect(session[:page]).to eq({ answer_type: type_of_answer_form.answer_type, answer_settings: nil })
        end

        it "redirects the user to the text settings page" do
          expect(response).to redirect_to text_settings_new_path(form.id)
        end
      end

      context "when answer type is date" do
        let(:type_of_answer_form) { build :type_of_answer_form, answer_type: "date", form: }

        before do
          post type_of_answer_create_path form_id: form.id, params: { forms_type_of_answer_form: { answer_type: type_of_answer_form.answer_type } }
        end

        it "saves the answer type to session" do
          expect(session[:page]).to eq({ answer_type: type_of_answer_form.answer_type, answer_settings: nil })
        end

        it "redirects the user to the date settings page" do
          expect(response).to redirect_to date_settings_new_path(form.id)
        end
      end

      context "when answer type is address" do
        let(:type_of_answer_form) { build :type_of_answer_form, answer_type: "address", form: }

        before do
          post type_of_answer_create_path form_id: form.id, params: { forms_type_of_answer_form: { answer_type: type_of_answer_form.answer_type } }
        end

        it "saves the answer type to session" do
          expect(session[:page]).to eq({ answer_type: type_of_answer_form.answer_type, answer_settings: nil })
        end

        it "redirects the user to the address settings page" do
          expect(response).to redirect_to address_settings_new_path(form.id)
        end
      end

      context "when answer type is name" do
        let(:type_of_answer_form) { build :type_of_answer_form, answer_type: "name", form: }

        before do
          post type_of_answer_create_path form_id: form.id, params: { forms_type_of_answer_form: { answer_type: type_of_answer_form.answer_type } }
        end

        it "saves the answer type to session" do
          expect(session[:page]).to eq({ answer_type: type_of_answer_form.answer_type, answer_settings: nil })
        end

        it "redirects the user to the name settings page" do
          expect(response).to redirect_to name_settings_new_path(form.id)
        end
      end
    end

    context "when form is invalid" do
      before do
        post type_of_answer_create_path form_id: form.id, params: { forms_type_of_answer_form: { answer_type: nil } }
      end

      it "renders the type of answer view if there are errors" do
        expect(response).to have_rendered("pages/type-of-answer")
      end
    end
  end

  describe "#edit" do
    let(:page) { build :page, :with_simple_answer_type, id: 2, form_id: form.id }

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

    it "returns the existing page answer type" do
      form = assigns(:type_of_answer_form)
      expect(form.answer_type).to eq page.answer_type
    end

    it "sets an instance variable for type_of_answer_path" do
      path = assigns(:type_of_answer_path)
      expect(path).to eq type_of_answer_edit_path(type_of_answer_form.form.id)
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/type-of-answer")
    end
  end

  describe "#update" do
    let(:page) { build :page, :with_simple_answer_type, id: 2, form_id: form.id, answer_type: "email" }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/2", req_headers, page.to_json, 200
        mock.put "/api/v1/forms/1/pages/2", post_headers
      end
    end

    context "when form is valid and ready to update in the DB" do
      before do
        post type_of_answer_update_path(form_id: page.form_id, page_id: page.id), params: { forms_type_of_answer_form: { answer_type: "number" } }
      end

      it "saves the updated answer type to DB" do
        form = assigns(:type_of_answer_form)
        expect(form.answer_type).to eq "number"
      end

      it "redirects the user to the question details page " do
        expect(response).to redirect_to edit_page_path(form.id, page.id)
      end
    end

    context "when form is invalid" do
      before do
        post type_of_answer_create_path form_id: form.id, params: { forms_type_of_answer_form: { answer_type: nil } }
      end

      it "renders the type of answer view if there are errors" do
        expect(response).to have_rendered("pages/type-of-answer")
      end
    end
  end
end
