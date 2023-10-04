require "rails_helper"

RSpec.describe Pages::GuidanceController, type: :request do
  let(:form) { build :form, id: 1 }
  let(:pages) { build_list :page, 5, form_id: form.id }
  let(:page) { pages.first }
  let(:page_heading) { "Page heading" }
  let(:guidance_markdown) { "## Heading level 2" }

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

  before do
    login_as_editor_user
  end

  describe "#new" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
      end

      get guidance_new_path(form_id: form.id)
    end

    it "reads the existing form" do
      expect(form).to have_been_read
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/guidance")
    end

    it "returns 200" do
      expect(response).to have_http_status(:ok)
    end

    it "links back to the previous question page" do
      expect(Capybara.string(response.body)).to have_link("Back", href: new_question_path(form.id))
    end

    it "includes a cancel link" do
      expect(Capybara.string(response.body)).to have_link(I18n.t("cancel"), href: new_question_path(form.id))
    end
  end

  describe "#create" do
    let(:route_to) { "preview" }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
      end
      post guidance_new_path(form_id: form.id), params: { pages_guidance_form: { page_heading:, guidance_markdown: }, route_to: }
    end

    context "when previewing markdown" do
      let(:route_to) { "preview" }

      it "reads the existing form" do
        expect(form).to have_been_read
      end

      it "renders the template" do
        expect(response).to have_rendered("pages/guidance")
      end

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the guidance markdown as html" do
        expect(response.body).to include('<h2 class="govuk-heading-m">Heading level 2</h2>')
      end

      it "links back to the previous question page" do
        expect(Capybara.string(response.body)).to have_link("Back", href: new_question_path(form.id))
      end

      it "includes a cancel link" do
        expect(Capybara.string(response.body)).to have_link(I18n.t("cancel"), href: new_question_path(form.id))
      end

      context "when markdown is blank" do
        let(:guidance_markdown) { "" }

        it "reads the existing form" do
          expect(form).to have_been_read
        end

        it "renders the template" do
          expect(response).to have_rendered("pages/guidance")
        end

        it "renders the default HTML" do
          expect(response.body).to include(I18n.t("guidance.no_guidance_added_html"))
        end

        it "returns 200" do
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context "when saving markdown" do
      let(:route_to) { "save_and_continue" }

      it "reads the existing form" do
        expect(form).to have_been_read
      end

      it "saves the page_heading and guidance_markdown to session" do
        expect(session[:page][:page_heading]).to eq("Page heading")
        expect(session[:page][:guidance_markdown]).to eq("## Heading level 2")
      end

      it "redirects the user to the new question page" do
        expect(response).to redirect_to new_question_path(form.id)
      end

      context "when data is invalid" do
        let(:page_heading) { nil }

        it "returns 422" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "renders the template" do
          expect(response).to have_rendered("pages/guidance")
        end
      end
    end
  end

  describe "#edit" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/#{page.id}", req_headers, page.to_json, 200
      end

      get guidance_edit_path(form_id: form.id, page_id: page.id)
    end

    it "reads the existing form" do
      expect(form).to have_been_read
    end

    it "renders the template" do
      expect(response).to have_rendered("pages/guidance")
    end

    it "returns 200" do
      expect(response).to have_http_status(:ok)
    end

    it "links back to the previous question page" do
      expect(Capybara.string(response.body)).to have_link("Back", href: edit_question_path(form.id, page.id))
    end

    it "includes a cancel link" do
      expect(Capybara.string(response.body)).to have_link(I18n.t("cancel"), href: edit_question_path(form.id, page.id))
    end
  end

  describe "#update" do
    let(:pages) { build_list :page, 5, :with_guidance, form_id: form.id }
    let(:route_to) { "preview" }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/#{page.id}", req_headers, page.to_json, 200
      end
      post guidance_update_path(form_id: form.id, page_id: page.id), params: { pages_guidance_form: { page_heading:, guidance_markdown: }, route_to: }
    end

    context "when previewing markdown" do
      let(:route_to) { "preview" }

      it "reads the existing form" do
        expect(form).to have_been_read
      end

      it "renders the template" do
        expect(response).to have_rendered("pages/guidance")
      end

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the guidance markdown as html" do
        expect(response.body).to include('<h2 class="govuk-heading-m">Heading level 2</h2>')
      end

      it "links back to the previous question page" do
        expect(Capybara.string(response.body)).to have_link("Back", href: edit_question_path(form.id, page.id))
      end

      it "includes a cancel link" do
        expect(Capybara.string(response.body)).to have_link(I18n.t("cancel"), href: edit_question_path(form.id, page.id))
      end

      context "when markdown is blank" do
        let(:guidance_markdown) { "" }

        it "reads the existing form" do
          expect(form).to have_been_read
        end

        it "renders the template" do
          expect(response).to have_rendered("pages/guidance")
        end

        it "renders the default HTML" do
          expect(response.body).to include(I18n.t("guidance.no_guidance_added_html"))
        end

        it "returns 200" do
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context "when saving markdown" do
      let(:route_to) { "save_and_continue" }

      it "reads the existing form" do
        expect(form).to have_been_read
      end

      it "saves the page_heading and guidance_markdown to session" do
        expect(session[:page][:page_heading]).to eq("Page heading")
        expect(session[:page][:guidance_markdown]).to eq("## Heading level 2")
      end

      it "redirects the user to the edit question page" do
        expect(response).to redirect_to edit_question_path(form.id, page.id)
      end

      context "when data is invalid" do
        let(:page_heading) { nil }

        it "returns 422" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "renders the template" do
          expect(response).to have_rendered("pages/guidance")
        end
      end
    end
  end

  describe "#render_preview" do
    let(:guidance_markdown) { "### Markdown" }

    before do
      post guidance_render_preview_path(form_id: form.id), params: { guidance_markdown: }
    end

    it "returns a JSON object containing the converted HTML" do
      expect(response.body).to eq({ preview_html: "<h3 class=\"govuk-heading-s\">Markdown</h3>", errors: [] }.to_json)
    end

    it "returns 200" do
      expect(response).to have_http_status(:ok)
    end

    context "when markdown is blank" do
      let(:guidance_markdown) { "" }

      it "returns a JSON object containing the converted HTML" do
        expect(response.body).to eq({ preview_html: I18n.t("guidance.no_guidance_added_html"), errors: [] }.to_json)
      end

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end
    end

    context "when markdown contains forbidden syntax" do
      let(:guidance_markdown) { "# A level one heading" }

      it "returns a JSON object containing the converted HTML" do
        expect(response.body).to eq({ preview_html: "<p class=\"govuk-body\">A level one heading</p>", errors: [I18n.t("activemodel.errors.models.pages/guidance_form.attributes.guidance_markdown.unsupported_markdown_syntax")] }.to_json)
      end

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
