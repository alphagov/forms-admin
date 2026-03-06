require "rails_helper"

RSpec.describe Pages::GuidanceController, type: :request do
  let(:form) { create :form, id: 1 }
  let(:pages) { create_list :page, 5, form_id: form.id }
  let(:page) { pages.first }
  let(:draft_question) { build :draft_question, form_id: form.id }
  let(:page_heading) { "Page heading" }
  let(:guidance_markdown) { "## Heading level 2" }

  let(:controller_spy) do
    controller_spy = described_class.new
    allow(described_class).to receive(:new).and_return(controller_spy)
    controller_spy
  end

  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as_standard_user
  end

  describe "#new" do
    before do
      get guidance_new_path(form_id: form.id)
    end

    it "links back to the previous question page and includes a cancel link" do
      expect(response).to have_http_status(:ok)
      expect(response).to have_rendered("pages/guidance")

      expect(Capybara.string(response.body)).to have_link("Back", href: new_question_path(form.id))
      expect(Capybara.string(response.body)).to have_link(I18n.t("cancel"), href: new_question_path(form.id))
    end
  end

  describe "#create" do
    let(:route_to) { "preview" }

    before do
      allow(controller_spy).to receive(:draft_question).and_return(draft_question)
      post guidance_new_path(form_id: form.id), params: { pages_guidance_input: { page_heading:, guidance_markdown: }, route_to: }
    end

    context "when previewing markdown" do
      let(:route_to) { "preview" }

      it "renders the guidance markdown as html with a link to the previous question page and a cancel link" do
        expect(response).to have_http_status(:ok)
        expect(response).to have_rendered("pages/guidance")
        expect(response.body).to include('<h2 class="govuk-heading-m">Heading level 2</h2>')
        expect(Capybara.string(response.body)).to have_link("Back", href: new_question_path(form.id))
        expect(Capybara.string(response.body)).to have_link(I18n.t("cancel"), href: new_question_path(form.id))
      end

      context "when markdown is blank" do
        let(:guidance_markdown) { "" }

        it "renders the default HTML" do
          expect(response).to have_http_status(:ok)
          expect(response).to have_rendered("pages/guidance")
          expect(response.body).to include(I18n.t("guidance.no_guidance_added_html"))
        end
      end
    end

    context "when saving markdown" do
      let(:route_to) { "save_and_continue" }

      it "saves the page_heading and guidance_markdown to session and redirects the user to the new question page" do
        expect(draft_question.page_heading).to eq("Page heading")
        expect(draft_question.guidance_markdown).to eq("## Heading level 2")
        expect(response).to redirect_to new_question_path(form.id)
      end

      context "when data is invalid" do
        let(:page_heading) { nil }

        it "renders the template and returns 422" do
          expect(response).to have_http_status(:unprocessable_content)
          expect(response).to have_rendered("pages/guidance")
        end
      end
    end
  end

  describe "#edit" do
    before do
      get guidance_edit_path(form_id: form.id, page_id: page.id)
    end

    it "links back to the previous question page and includes a cancel link" do
      expect(response).to have_http_status(:ok)
      expect(response).to have_rendered("pages/guidance")
      expect(Capybara.string(response.body)).to have_link("Back", href: edit_question_path(form.id, page.id))
      expect(Capybara.string(response.body)).to have_link(I18n.t("cancel"), href: edit_question_path(form.id, page.id))
    end
  end

  describe "#update" do
    let(:pages) { create_list :page, 5, :with_guidance, form_id: form.id }
    let(:route_to) { "preview" }

    before do
      allow(controller_spy).to receive(:draft_question).and_return(draft_question)
      post guidance_update_path(form_id: form.id, page_id: page.id), params: { pages_guidance_input: { page_heading:, guidance_markdown: }, route_to: }
    end

    context "when previewing markdown" do
      let(:route_to) { "preview" }

      it "renders the guidance markdown as html with a link to the previous question page and a cancel link" do
        expect(response).to have_http_status(:ok)
        expect(response).to have_rendered("pages/guidance")
        expect(response.body).to include('<h2 class="govuk-heading-m">Heading level 2</h2>')
        expect(Capybara.string(response.body)).to have_link("Back", href: edit_question_path(form.id, page.id))
        expect(Capybara.string(response.body)).to have_link(I18n.t("cancel"), href: edit_question_path(form.id, page.id))
      end

      context "when markdown is blank" do
        let(:guidance_markdown) { "" }

        it "renders the default HTML" do
          expect(response).to have_http_status(:ok)
          expect(response).to have_rendered("pages/guidance")
          expect(response.body).to include(I18n.t("guidance.no_guidance_added_html"))
        end
      end
    end

    context "when saving markdown" do
      let(:route_to) { "save_and_continue" }

      it "saves the page_heading and guidance_markdown to session and redirects the user to the edit question page" do
        expect(draft_question.page_heading).to eq("Page heading")
        expect(draft_question.guidance_markdown).to eq("## Heading level 2")
        expect(response).to redirect_to edit_question_path(form.id, page.id)
      end

      context "when data is invalid" do
        let(:page_heading) { nil }

        it "renders the template and returns 422" do
          expect(response).to have_http_status(:unprocessable_content)
          expect(response).to have_rendered("pages/guidance")
        end
      end
    end
  end

  describe "#render_preview" do
    let(:markdown) { "[Markdown](https://example.com)" }

    before do
      post guidance_render_preview_path(form_id: form.id), params: { markdown: }
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
        expect(response.body).to eq({ preview_html: I18n.t("guidance.no_guidance_added_html"), errors: [] }.to_json)
      end
    end

    context "when markdown contains forbidden syntax" do
      let(:markdown) { "# A level one heading" }

      it "returns a JSON object containing the converted HTML" do
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq({ preview_html: "<p class=\"govuk-body\">A level one heading</p>", errors: [I18n.t("activemodel.errors.models.pages/guidance_input.attributes.guidance_markdown.unsupported_markdown_syntax")] }.to_json)
      end
    end
  end
end
