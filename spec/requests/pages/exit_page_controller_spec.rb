require "rails_helper"

RSpec.describe Pages::ExitPageController, type: :request do
  let(:form) { build :form, :ready_for_routing, id: 1 }
  let(:pages) { form.pages }
  let(:page) do
    pages.first.tap do |first_page|
      first_page.is_optional = false
      first_page.answer_type = "selection"
      first_page.answer_settings = DataStruct.new(
        only_one_option: true,
        selection_options: [OpenStruct.new(attributes: { name: answer_value }),
                            OpenStruct.new(attributes: { name: "Option 2" })],
      )
    end
  end
  let(:selected_page) { page }
  let(:answer_value) { "Option 1" }

  let(:exit_pages_enabled) { true }

  let(:group) { create(:group, organisation: standard_user.organisation, exit_pages_enabled:) }
  let(:user) { standard_user }
  let(:condition) { build(:condition, id: 1, form_id: form.id, page_id: page.id, exit_page_heading: "Exit Page Heading") }

  before do
    allow(FormRepository).to receive_messages(find: form, pages: pages)
    allow(PageRepository).to receive_messages(find: selected_page)

    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as user
  end

  describe "#new" do
    before do
      get new_exit_page_path(form_id: form.id, page_id: selected_page.id, answer_value: answer_value)
    end

    it "renders the new exit page template" do
      expect(response).to render_template("pages/exit_page/new")
    end

    context "when user should not be allowed to add routes to pages" do
      let(:form) { build :form, id: 1 }
      let(:pages) { [build(:page)] }

      it "Renders the forbidden page" do
        expect(response).to render_template("errors/forbidden")
      end

      it "Returns a 403 status" do
        expect(response.status).to eq(403)
      end
    end

    context "when group the form is in should not be allowed to add exit pages" do
      let(:exit_pages_enabled) { false }

      it "Returns a 404 status" do
        expect(response.status).to eq(404)
      end
    end

    context "when there is no answer value param" do
      let(:answer_value) { nil }

      it "redirects to the new condition page" do
        expect(response).to redirect_to new_condition_path(form.id, selected_page.id)
      end
    end
  end

  describe "#create" do
    let(:params) { { pages_exit_page_input: { exit_page_heading: "Exit Page Heading", exit_page_markdown: "Exit Page Markdown", answer_value: } } }

    before do
      allow(PageRepository).to receive(:find).and_return(selected_page)
      allow(ConditionRepository).to receive(:create!).and_return(true)

      post create_exit_page_path(form_id: form.id, page_id: selected_page.id, params:)
    end

    it "redirects to the show routes page" do
      expect(response).to redirect_to show_routes_path(form:, page:)
    end

    it "displays success message" do
      follow_redirect!
      expect(response.body).to include(I18n.t("banner.success.exit_page_created"))
    end

    context "when there is no answer value submitted" do
      let(:answer_value) { nil }

      it "redirects to the new condition page" do
        expect(response).to redirect_to new_condition_path(form.id, selected_page.id)
      end
    end

    context "when form submit fails" do
      let(:params) { { pages_exit_page_input: { exit_page_heading: nil, exit_page_markdown: nil, answer_value: } } }

      it "return 422 error code" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders new page" do
        expect(response).to render_template("pages/exit_page/new")
      end
    end

    context "when user should not be allowed to add routes to pages" do
      let(:form) { build :form, id: 1 }
      let(:pages) { [build(:page)] }

      it "Renders the forbidden page" do
        expect(response).to render_template("errors/forbidden")
      end

      it "Returns a 403 status" do
        expect(response.status).to eq(403)
      end
    end

    context "when group the form is in should not be allowed to add exit pages" do
      let(:exit_pages_enabled) { false }

      it "Returns a 404 status" do
        expect(response.status).to eq(404)
      end
    end
  end

  describe "#edit" do
    let(:condition) { build :condition, :with_exit_page, id: 3, form:, page: selected_page }

    before do
      allow(ConditionRepository).to receive(:find).and_return(condition)

      get edit_exit_page_path(form_id: form.id, page_id: selected_page.id, condition_id: condition.id)
    end

    it "renders the edit exit page template" do
      expect(response).to render_template("pages/exit_page/edit")
    end

    context "when the group the form is in should not be allowed to manipulate exit pages" do
      let(:exit_pages_enabled) { false }

      it "Returns a 404 status" do
        expect(response.status).to eq(404)
      end
    end
  end

  describe "#update" do
    let(:condition) { build :condition, :with_exit_page, id: 3, form:, page: selected_page }
    let(:params) { { pages_update_exit_page_input: { exit_page_heading: "Exit Page Heading", exit_page_markdown: "Exit Page Markdown" } } }

    before do
      allow(ConditionRepository).to receive_messages(save!: true, find: condition)

      put update_exit_page_path(form_id: form.id, page_id: selected_page.id, condition_id: condition.id, params:)
    end

    it "redirects to the edit condition page" do
      expect(response).to redirect_to edit_condition_path(form:, page:, condition:)
    end

    it "displays success message" do
      follow_redirect!
      expect(response.body).to include(I18n.t("banner.success.exit_page_updated"))
    end

    context "when the group the form is in should not be allowed to manipulate exit pages" do
      let(:exit_pages_enabled) { false }

      it "Returns a 404 status" do
        expect(response.status).to eq(404)
      end
    end

    context "when form submit fails" do
      let(:params) { { pages_update_exit_page_input: { exit_page_heading: nil, exit_page_markdown: nil } } }

      it "return 422 error code" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders edit page" do
        expect(response).to render_template("pages/exit_page/edit")
      end
    end
  end

  describe "#delete" do
    before do
      allow(ConditionRepository).to receive(:find).and_return(condition)
      allow(condition).to receive(:exit_page?).and_return(true)

      get delete_exit_page_path(form_id: form.id, page_id: selected_page.id, condition_id: condition.id)
    end

    it "renders the delete exit page template" do
      expect(response).to render_template("pages/exit_page/delete")
    end

    it "assigns the exit page" do
      expect(assigns(:exit_page)).to eq(condition)
    end

    it "assigns a new delete exit page input" do
      expect(assigns(:delete_exit_page_input)).to be_a(Pages::DeleteExitPageInput)
    end

    context "when user should not be allowed to add/delete routes to pages" do
      let(:form) { build :form, id: 1 }
      let(:pages) { [build(:page)] }

      it "renders the forbidden page" do
        expect(response).to render_template("errors/forbidden")
      end

      it "returns a 403 status" do
        expect(response.status).to eq(403)
      end
    end

    context "when group the form is in should not be allowed to add/delete exit pages" do
      let(:exit_pages_enabled) { false }

      it "returns a 404 status" do
        expect(response.status).to eq(404)
      end
    end
  end

  describe "#destroy" do
    let(:params) { { pages_delete_exit_page_input: { confirm: "yes" } } }

    before do
      allow(condition).to receive(:exit_page?).and_return(true)
      allow(ConditionRepository).to receive_messages(find: condition, destroy: true)

      delete destroy_exit_page_path(form_id: form.id, page_id: selected_page.id, condition_id: condition.id, params:)
    end

    it "redirects to form pages path" do
      expect(response).to redirect_to(form_pages_path(form.id))
    end

    it "displays success message" do
      follow_redirect!

      expect(response.body).to include(I18n.t("banner.success.exit_page_deleted"))
    end

    it "deletes the exit page" do
      expect(ConditionRepository).to have_received(:destroy).with(condition)
    end

    context "when confirmation is not provided" do
      let(:params) { { pages_delete_exit_page_input: { confirm: nil } } }

      it "renders the delete template again" do
        expect(response).to render_template("pages/exit_page/delete")
      end
    end

    context "when confirmation is no" do
      let(:params) { { pages_delete_exit_page_input: { confirm: "no" } } }

      it "redirects to form pages path" do
        expect(response).to redirect_to(edit_exit_page_path(form.id, page.id, condition.id))
      end

      it "doesn't delete the exit page" do
        expect(ConditionRepository).not_to have_received(:destroy)
      end
    end

    context "when the condition is not an exit page" do
      before do
        allow(condition).to receive(:exit_page?).and_return(false)
        delete destroy_exit_page_path(form_id: form.id, page_id: selected_page.id, condition_id: condition.id, params:)
      end

      it "redirects to the form pages page" do
        expect(response).to redirect_to(form_pages_path(form.id))
      end
    end

    context "when deletion fails" do
      before do
        allow(ConditionRepository).to receive(:destroy).and_return(false)
        delete destroy_exit_page_path(form_id: form.id, page_id: selected_page.id, condition_id: condition.id, params:)
      end

      it "redirects to form pages path" do
        expect(response).to redirect_to(form_pages_path(form.id))
      end
    end

    context "when user should not be allowed to add/delete routes to pages" do
      let(:form) { build :form, id: 1 }
      let(:pages) { [build(:page)] }

      it "renders the forbidden page" do
        expect(response).to render_template("errors/forbidden")
      end

      it "returns a 403 status" do
        expect(response.status).to eq(403)
      end
    end

    context "when group the form is in should not be allowed to add/delete exit pages" do
      let(:exit_pages_enabled) { false }

      it "returns a 404 status" do
        expect(response.status).to eq(404)
      end
    end
  end
end
