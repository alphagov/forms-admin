require "rails_helper"

RSpec.describe Pages::ConditionsController, type: :request do
  let(:form) { build :form, :ready_for_routing, id: 1 }
  let(:pages) { form.pages }
  let(:page) do
    pages.first.tap do |first_page|
      first_page.is_optional = false
      first_page.answer_type = "selection"
      first_page.answer_settings = DataStruct.new(
        only_one_option: true,
        selection_options: [OpenStruct.new(attributes: { name: "Option 1" }),
                            OpenStruct.new(attributes: { name: "Option 2" })],
      )
    end
  end
  let(:selected_page) { page }

  let(:submit_result) { true }

  let(:group) { create(:group, organisation: standard_user.organisation) }
  let(:user) { standard_user }

  before do
    allow(FormRepository).to receive_messages(find: form, pages: pages)

    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as user
  end

  describe "#routing_page" do
    before do
      get routing_page_path(form_id: form.id)
    end

    it "reads the form" do
      expect(FormRepository).to have_received(:find)
    end

    it "renders the routing page template" do
      expect(response).to render_template("pages/conditions/routing_page")
    end
  end

  describe "#set_routing_page" do
    let(:params) { { pages_routing_page_input: { routing_page_id: 1 } } }

    before do
      selected_page.id = 1

      allow(PageRepository).to receive(:find).with(page_id: "1", form_id: 1).and_return(selected_page)

      post routing_page_path(form_id: 1, params:)
    end

    it "reads the form" do
      expect(FormRepository).to have_received(:find)
    end

    it "redirects the user to the new conditions page" do
      expect(response).to redirect_to new_condition_path(form.id, selected_page.id)
    end

    context "when the page already has a condition associated with it" do
      let(:selected_page) do
        page.routing_conditions = [(build :condition, id: 1, check_page_id: page.id, goto_page_id: 2)]
        page
      end

      it "when branch_routing enabled, redirects the user to the new skip condition page", :feature_branch_routing do
        expect(response).to redirect_to new_secondary_skip_path(form.id, selected_page.id)
      end

      it "when branch_routing disabled, redirects the user to the new conditions page" do
        expect(response).to redirect_to new_condition_path(form.id, selected_page.id)
      end
    end

    context "when user should not be allowed to add routes to pages" do
      let(:user) { build :user }

      it "Renders the forbidden page" do
        expect(response).to render_template("errors/forbidden")
      end

      it "Returns a 403 status" do
        expect(response.status).to eq(403)
      end
    end

    context "when the routing page is not set" do
      let(:params) { { pages_routing_page_input: { routing_page_id: nil } } }

      it "renders the routing page view" do
        expect(response).to render_template("pages/conditions/routing_page")
      end

      it "Returns a 422 status" do
        expect(response.status).to eq(422)
      end
    end
  end

  describe "#new" do
    before do
      selected_page.id = 1

      allow(PageRepository).to receive(:find).and_return(selected_page)

      get new_condition_path(form_id: 1, page_id: 1)
    end

    it "reads the form" do
      expect(FormRepository).to have_received(:find)
    end

    it "renders the new condition page template" do
      expect(response).to render_template("pages/conditions/new")
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
  end

  describe "#create" do
    before do
      selected_page.id = 1

      allow(PageRepository).to receive(:find).and_return(selected_page)

      conditions_input = Pages::ConditionsInput.new(form:, page: selected_page, answer_value: "Yes", goto_page_id: 3)

      allow(conditions_input).to receive(:submit).and_return(submit_result)

      allow(Pages::ConditionsInput).to receive(:new).and_return(conditions_input)

      post create_condition_path(form_id: form.id, page_id: selected_page.id, params: { pages_conditions_input: { routing_page_id: 1, check_page_id: 1, goto_page_id: 3, answer_value: "Wales" } })
    end

    it "reads the form" do
      expect(FormRepository).to have_received(:find)
    end

    it "redirects to the page list" do
      expect(response).to redirect_to show_routes_path(form:, page:)
    end

    it "displays success message" do
      follow_redirect!
      expect(response.body).to include(I18n.t("banner.success.route_created", question_position: selected_page.position))
    end

    context "when form submit fails" do
      let(:submit_result) { false }

      it "return 422 error code" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders new page" do
        expect(response).to render_template("pages/conditions/new")
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
  end

  describe "#edit" do
    let(:condition) { build :condition, id: 1, routing_page_id: 1, check_page_id: 1, answer_value: "Wales", goto_page_id: 3 }
    let(:conditions_input) { Pages::ConditionsInput.new(form:, page: selected_page, record: condition, answer_value: condition.answer_value, goto_page_id: condition.goto_page_id) }

    before do
      selected_page.routing_conditions = [condition]
      selected_page.position = 1

      allow(PageRepository).to receive(:find).and_return(selected_page)
      allow(ConditionRepository).to receive(:find).and_return(condition)

      allow(Pages::ConditionsInput).to receive(:new).and_return(conditions_input)
      allow(conditions_input).to receive(:check_errors_from_api)
      allow(conditions_input).to receive(:assign_condition_values).and_return(conditions_input)

      get edit_condition_path(form_id: 1, page_id: selected_page.id, condition_id: condition.id)
    end

    it "reads the form" do
      expect(FormRepository).to have_received(:find)
    end

    it "Checks the errors from the API response" do
      expect(conditions_input).to have_received(:check_errors_from_api).exactly(1).times
    end

    it "Calls assign_condition_values" do
      expect(conditions_input).to have_received(:assign_condition_values).exactly(1).times
    end

    it "renders the new condition page template" do
      expect(response).to render_template("pages/conditions/edit")
    end

    context "when user should not be allowed to add routes to pages" do
      let(:user) { build :user }

      it "Renders the forbidden page" do
        expect(response).to render_template("errors/forbidden")
      end

      it "Returns a 403 status" do
        expect(response.status).to eq(403)
      end
    end
  end

  describe "#update" do
    let(:condition) { build :condition, id: 1, routing_page_id: pages.first.id, check_page_id: pages.first.id, answer_value: "Wales", goto_page_id: pages.last.id }

    before do
      selected_page.routing_conditions = [condition]
      selected_page.position = 1

      allow(PageRepository).to receive(:find).and_return(selected_page)
      allow(ConditionRepository).to receive(:find).and_return(condition)

      conditions_input = Pages::ConditionsInput.new(form:, page: selected_page, record: condition, answer_value: "Yes", goto_page_id: 3)

      allow(conditions_input).to receive(:update_condition).and_return(submit_result)

      allow(Pages::ConditionsInput).to receive(:new).and_return(conditions_input)

      put update_condition_path(form_id: form.id,
                                page_id: selected_page.id,
                                condition_id: condition.id,
                                params: { pages_conditions_input: { routing_page_id: 1, check_page_id: 1, goto_page_id: 3, answer_value: "Wales" } })
    end

    it "reads the form" do
      expect(FormRepository).to have_received(:find)
    end

    it "redirects to the page list" do
      expect(response).to redirect_to show_routes_path(form:, page:)
    end

    it "displays success message" do
      follow_redirect!
      expect(response.body).to include(I18n.t("banner.success.route_updated", question_position: 1))
    end

    context "when form submit fails" do
      let(:submit_result) { false }

      it "return 422 error code" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders new page" do
        expect(response).to render_template("pages/conditions/edit")
      end
    end

    context "when user should not be allowed to add routes to pages" do
      let(:user) { build :user }

      it "Renders the forbidden page" do
        expect(response).to render_template("errors/forbidden")
      end

      it "Returns a 403 status" do
        expect(response.status).to eq(403)
      end
    end
  end

  describe "#delete" do
    let(:condition) { build :condition, id: 1, routing_page_id: 1, check_page_id: 1, answer_value: "Wales", goto_page_id: 3 }

    before do
      selected_page.routing_conditions = [condition]
      selected_page.position = 1

      allow(PageRepository).to receive(:find).and_return(selected_page)

      allow(ConditionRepository).to receive(:find).and_return(condition)

      delete_condition_input = Pages::DeleteConditionInput.new(form:, page: selected_page, record: condition, answer_value: "Yes", goto_page_id: 3)

      allow(delete_condition_input).to receive(:goto_page_question_text).and_return("What is your name?")

      allow(Pages::DeleteConditionInput).to receive(:new).and_return(delete_condition_input)

      get delete_condition_path(form_id: 1, page_id: selected_page.id, condition_id: condition.id)
    end

    it "reads the form" do
      expect(FormRepository).to have_received(:find)
    end

    it "renders the delete condition page template" do
      expect(response).to render_template("pages/conditions/delete")
    end

    context "when user should not be allowed to add routes to pages" do
      let(:user) { build :user }

      it "Renders the forbidden page" do
        expect(response).to render_template("errors/forbidden")
      end

      it "Returns a 403 status" do
        expect(response.status).to eq(403)
      end
    end
  end

  describe "#destroy" do
    let(:condition) { build :condition, id: 1, routing_page_id: pages.first.id, check_page_id: pages.first.id, answer_value: "Wales", goto_page_id: pages.last.id }
    let(:confirm) { "yes" }
    let(:submit_bool) { true }

    before do
      selected_page.routing_conditions = [condition]
      selected_page.position = 1

      allow(PageRepository).to receive(:find).and_return(selected_page)
      allow(ConditionRepository).to receive_messages(find: condition, destroy: nil)

      delete_condition_input = Pages::DeleteConditionInput.new(form:, page: selected_page, record: condition, answer_value: "Wales", goto_page_id: 3, confirm:)

      allow(delete_condition_input).to receive_messages(goto_page_question_text: "What is your name?", submit: submit_bool)

      allow(Pages::DeleteConditionInput).to receive(:new).and_return(delete_condition_input)

      delete destroy_condition_path(form_id: form.id,
                                    page_id: selected_page.id,
                                    condition_id: condition.id,
                                    params: { pages_delete_condition_input: { confirm:, goto_page_id: 3, answer_value: "Wales" } })
    end

    it "reads the form" do
      expect(FormRepository).to have_received(:find)
    end

    it "redirects to the page list" do
      expect(response).to redirect_to form_pages_path(form.id, selected_page.id)
    end

    it "displays success message" do
      follow_redirect!
      expect(response.body).to include(I18n.t("banner.success.route_deleted", question_position: 1))
    end

    context "when confirm deletion is false" do
      let(:confirm) { "no" }

      it "redirects to edit the condition" do
        expect(response).to redirect_to edit_condition_path(form.id, selected_page.id, condition.id)
      end
    end

    context "when the destroy fails" do
      let(:submit_bool) { false }

      it "return 422 error code" do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when form submit fails" do
      let(:submit_bool) { false }
      let(:confirm) { nil }

      it "return 422 error code" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders the delete page" do
        expect(response).to render_template("pages/conditions/delete")
      end
    end

    context "when user should not be allowed to add routes to pages" do
      let(:user) { build :user }

      it "Renders the forbidden page" do
        expect(response).to render_template("errors/forbidden")
      end

      it "Returns a 403 status" do
        expect(response.status).to eq(403)
      end
    end
  end
end
