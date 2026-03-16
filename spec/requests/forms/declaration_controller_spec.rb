require "rails_helper"

RSpec.describe Forms::DeclarationController, type: :request do
  let(:form) do
    create(
      :form,
      name: "Form name",
      submission_email: "submission@email.com",
      declaration_markdown: "",
    )
  end

  let(:user) { standard_user }
  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)

    login_as user
  end

  describe "#new" do
    before do
      get declaration_path(form_id: form.id)
    end

    context "when the user is not authorised to view the form" do
      let(:user) { build :user }

      it "returns 403" do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "#create" do
    let(:declaration_markdown) { "Wait until you get a reply" }
    let(:mark_complete) { "true" }
    let(:route_to) { "save_and_continue" }
    let(:params) { { forms_declaration_input: { declaration_markdown:, mark_complete: }, route_to: } }

    it "Updates the form and redirects to the form overview page" do
      expect {
        post(declaration_path(form_id: form.id), params:)
      }.to change { form.reload.declaration_markdown }.to(declaration_markdown).and change { response }.to redirect_to(form_path(form.id))
    end

    context "when previewing markdown" do
      let(:route_to) { "preview" }
      let(:declaration_markdown) { "### A heading\n\n[a link](https://example.com)" }

      before do
        post(declaration_path(form_id: form.id), params:)
      end

      it "renders the markdown as html" do
        expect(response).to have_rendered("forms/declaration/new")
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('<a href="https://example.com" class="govuk-link" rel="noreferrer noopener" target="_blank">a link (opens in new tab)</a>')
        expect(response.body).to include('<h3 class="govuk-heading-s">A heading</h3>')
      end

      context "when markdown is invalid" do
        let(:declaration_markdown) { "# A level one heading" }

        it "returns 422 and renders the `new` template" do
          expect(response).to have_http_status(:unprocessable_content)
          expect(response).to have_rendered("forms/declaration/new")
        end
      end

      context "when the user is not authorised to view the form" do
        let(:user) { build :user }

        it "returns 403" do
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context "when saving markdown" do
      let(:route_to) { "save_and_continue" }

      before do
        post(declaration_path(form_id: form.id), params:)
      end

      it "redirects the user to the form overview page" do
        expect(response).to redirect_to(form_path(form.id))
      end

      context "when markdown is invalid" do
        let(:declaration_markdown) { "# A level one heading" }

        it "returns 422 and renders the `new` template" do
          expect(response).to have_http_status(:unprocessable_content)
          expect(response).to have_rendered("forms/declaration/new")
        end
      end
    end
  end

  describe "#render_preview" do
    let(:markdown) { "[Markdown](https://example.com)" }

    before do
      post declaration_render_preview_path(form_id: form.id), params: { markdown: }
    end

    it "returns a JSON object containing the converted HTML" do
      expect(response).to have_http_status(:ok)
      expect(response.body).to eq({
        preview_html: "<p class=\"govuk-body\"><a href=\"https://example.com\" class=\"govuk-link\" rel=\"noreferrer noopener\" target=\"_blank\">Markdown (opens in new tab)</a></p>",
        errors: [],
      }.to_json)
    end

    context "when markdown is blank" do
      let(:markdown) { "" }

      it "returns a JSON object containing the converted HTML" do
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq({ preview_html: I18n.t("markdown_editor.no_markdown_content_html"), errors: [] }.to_json)
      end
    end

    context "when markdown contains forbidden syntax" do
      let(:markdown) { "# A level one heading" }

      it "returns a JSON object containing the converted HTML" do
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq({ preview_html: "<p class=\"govuk-body\">A level one heading</p>", errors: [I18n.t("activemodel.errors.models.forms/declaration_input.attributes.declaration_markdown.unsupported_markdown_syntax")] }.to_json)
      end
    end

    context "when the user is not authorised to view the form" do
      let(:user) { build :user }

      it "returns 403" do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
