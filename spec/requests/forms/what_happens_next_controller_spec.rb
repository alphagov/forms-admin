require "rails_helper"

RSpec.describe Forms::WhatHappensNextController, type: :request do
  let(:form_response_data) do
    {
      id: 2,
      name: "Form name",
      submission_email: "submission@email.com",
      start_page: 1,
      organisation_id: 1,
      what_happens_next_markdown: "Good things come to those who wait",
      live_at: nil,
    }.to_json
  end

  let(:form) do
    Form.new(
      name: "Form name",
      submission_email: "submission@email.com",
      id: 2,
      organisation_id: 1,
      what_happens_next_markdown: "",
      live_at: nil,
    )
  end

  let(:updated_form) do
    Form.new({
      name: "Form name",
      submission_email: "submission@email.com",
      id: 2,
      organisation_id: 1,
      what_happens_next_markdown: "Wait until you get a reply",
      live_at: nil,
    })
  end

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms/2", headers, form.to_json, 200
      mock.put "/api/v1/forms/2", headers
    end

    ActiveResourceMock.mock_resource(form,
                                     {
                                       read: { response: form, status: 200 },
                                       update: { response: updated_form, status: 200 },
                                     })

    login_as_editor_user
  end

  describe "#new" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.put "/api/v1/forms/2", post_headers
        mock.get "/api/v1/forms/2", headers, form.to_json, 200
      end
      allow(Pundit).to receive(:authorize).and_return(true)
      get what_happens_next_path(form_id: 2)
    end

    it "checks the user is authorised to view the form" do
      expect(Pundit).to have_received(:authorize)
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end
  end

  describe "#create" do
    let(:what_happens_next_markdown) { "Wait until you get a reply" }
    let(:route_to) { "save_and_continue" }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/2", headers, form.to_json, 200
        mock.put "/api/v1/forms/2", post_headers
      end
      allow(Pundit).to receive(:authorize).and_return(true)
      post what_happens_next_path(form_id: 2), params: { forms_what_happens_next_form: { what_happens_next_markdown: }, route_to: }
    end

    it "checks the user is authorised to view the form" do
      expect(Pundit).to have_received(:authorize)
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

    context "when previewing markdown" do
      let(:route_to) { "preview" }
      let(:what_happens_next_markdown) { "[a link](https://example.com)" }

      it "reads the existing form" do
        expect(form).to have_been_read
      end

      it "renders the what happens next template" do
        expect(response).to have_rendered("forms/what_happens_next/new")
      end

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the guidance markdown as html" do
        expect(response.body).to include('<a href="https://example.com" class="govuk-link" rel="noreferrer noopener" target="_blank">a link (opens in new tab)</a>')
      end

      context "when markdown is invalid" do
        let(:what_happens_next_markdown) { "# A level one heading" }

        it "reads the existing form" do
          expect(form).to have_been_read
        end

        it "renders the template" do
          expect(response).to have_rendered("forms/what_happens_next/new")
        end

        it "returns 422" do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "when saving markdown" do
      let(:route_to) { "save_and_continue" }

      it "reads the existing form" do
        expect(form).to have_been_read
      end

      it "redirects the user to the form overview page" do
        expect(response).to redirect_to(form_path(2))
      end

      context "when markdown is invalid" do
        let(:what_happens_next_markdown) { "# A level one heading" }

        it "returns 422" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "renders the template" do
          expect(response).to have_rendered("forms/what_happens_next/new")
        end
      end
    end
  end

  describe "#render_preview" do
    let(:markdown) { "- Markdown" }

    before do
      allow(Pundit).to receive(:authorize).and_return(true)
      post what_happens_next_render_preview_path(form_id: form.id), params: { markdown: }
    end

    it "checks the user is authorised to view the form" do
      expect(Pundit).to have_received(:authorize)
    end

    it "returns a JSON object containing the converted HTML" do
      expect(response.body).to eq({ preview_html: "<ul class=\"govuk-list govuk-list--bullet\">\n  <li>Markdown</li>\n\n</ul>", errors: [] }.to_json)
    end

    it "returns 200" do
      expect(response).to have_http_status(:ok)
    end

    context "when markdown is blank" do
      let(:markdown) { "" }

      it "returns a JSON object containing the converted HTML" do
        expect(response.body).to eq({ preview_html: I18n.t("guidance.no_guidance_added_html"), errors: [] }.to_json)
      end

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end
    end

    context "when markdown contains forbidden syntax" do
      let(:markdown) { "# A level one heading" }

      it "returns a JSON object containing the converted HTML" do
        expect(response.body).to eq({ preview_html: "<p class=\"govuk-body\">A level one heading</p>", errors: [I18n.t("activemodel.errors.models.forms/what_happens_next_form.attributes.what_happens_next_markdown.unsupported_markdown_syntax")] }.to_json)
      end

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
