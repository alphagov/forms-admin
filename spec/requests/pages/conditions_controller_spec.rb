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

  let(:headers) do
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

  let(:expected_to_raise_error) { false }

  before do
    login_as_editor_user
  end

  describe "#routing_page" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", headers, pages.to_json, 200
      end

      get routing_page_path(form_id: form.id)
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end

    it "renders the routing page template" do
      expect(response).to render_template("pages/conditions/routing_page")
    end
  end

  describe "#set_routing_page" do
    let(:params) { { pages_routing_page_form: { routing_page_id: 1 } } }

    before do
      selected_page.id = 1
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/1", headers, selected_page.to_json, 200
      end

      if expected_to_raise_error
        allow(Pundit).to receive(:authorize).and_raise(Pundit::NotAuthorizedError)
      else
        allow(Pundit).to receive(:authorize).and_return(true)
      end

      post routing_page_path(form_id: 1, params:)
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end

    it "redirects the user to the new conditions page" do
      expect(response).to redirect_to new_condition_path(form.id, selected_page.id)
    end

    context "when user should not be allowed to add routes to pages" do
      let(:expected_to_raise_error) { true }

      it "Renders the forbidden page" do
        expect(response).to render_template("errors/forbidden")
      end

      it "Returns a 403 status" do
        expect(response.status).to eq(403)
      end
    end

    context "when the routing page is not set" do
      let(:params) { { pages_routing_page_form: { routing_page_id: nil } } }

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
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/1", headers, selected_page.to_json, 200
      end

      if expected_to_raise_error
        allow(Pundit).to receive(:authorize).and_raise(Pundit::NotAuthorizedError)
      else
        allow(Pundit).to receive(:authorize).and_return(true)
      end

      get new_condition_path(form_id: 1, page_id: 1)
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end

    it "renders the new condition page template" do
      expect(response).to render_template("pages/conditions/new")
    end

    context "when user should not be allowed to add routes to pages" do
      let(:expected_to_raise_error) { true }

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
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/1", headers, selected_page.to_json, 200
      end

      if expected_to_raise_error
        allow(Pundit).to receive(:authorize).and_raise(Pundit::NotAuthorizedError)
      else
        allow(Pundit).to receive(:authorize).and_return(true)
      end

      conditional_form = Pages::ConditionsForm.new(form:, page: selected_page, answer_value: "Yes", goto_page_id: 3)

      allow(conditional_form).to receive(:submit).and_return(submit_result)

      allow(Pages::ConditionsForm).to receive(:new).and_return(conditional_form)

      post create_condition_path(form_id: form.id, page_id: selected_page.id, params: { pages_conditions_form: { routing_page_id: 1, check_page_id: 1, goto_page_id: 3, answer_value: "Wales" } })
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end

    it "redirects to the page list" do
      expect(response).to redirect_to form_pages_path(form.id)
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
      let(:expected_to_raise_error) { true }

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
    let(:conditions_form) { Pages::ConditionsForm.new(form:, page: selected_page, record: condition, answer_value: condition.answer_value, goto_page_id: condition.goto_page_id) }

    before do
      selected_page.routing_conditions = [condition]
      selected_page.position = 1
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/#{selected_page.id}", headers, selected_page.to_json, 200
        mock.get "/api/v1/forms/1/pages/#{selected_page.id}/conditions/1", headers, condition.to_json, 200
      end

      if expected_to_raise_error
        allow(Pundit).to receive(:authorize).and_raise(Pundit::NotAuthorizedError)
      else
        allow(Pundit).to receive(:authorize).and_return(true)
      end

      allow(Pages::ConditionsForm).to receive(:new).and_return(conditions_form)
      allow(conditions_form).to receive(:check_errors_from_api)
      allow(conditions_form).to receive(:assign_condition_values).and_return(conditions_form)

      get edit_condition_path(form_id: 1, page_id: selected_page.id, condition_id: condition.id)
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end

    it "Checks the errors from the API response" do
      expect(conditions_form).to have_received(:check_errors_from_api).exactly(1).times
    end

    it "Calls assign_condition_values" do
      expect(conditions_form).to have_received(:assign_condition_values).exactly(1).times
    end

    it "renders the new condition page template" do
      expect(response).to render_template("pages/conditions/edit")
    end

    context "when user should not be allowed to add routes to pages" do
      let(:expected_to_raise_error) { true }

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
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/#{selected_page.id}", headers, selected_page.to_json, 200
        mock.get "/api/v1/forms/1/pages/#{selected_page.id}/conditions/1", headers, condition.to_json, 200
      end

      if expected_to_raise_error
        allow(Pundit).to receive(:authorize).and_raise(Pundit::NotAuthorizedError)
      else
        allow(Pundit).to receive(:authorize).and_return(true)
      end

      conditional_form = Pages::ConditionsForm.new(form:, page: selected_page, record: condition, answer_value: "Yes", goto_page_id: 3)

      allow(conditional_form).to receive(:update_condition).and_return(submit_result)

      allow(Pages::ConditionsForm).to receive(:new).and_return(conditional_form)

      put update_condition_path(form_id: form.id,
                                page_id: selected_page.id,
                                condition_id: condition.id,
                                params: { pages_conditions_form: { routing_page_id: 1, check_page_id: 1, goto_page_id: 3, answer_value: "Wales" } })
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end

    it "redirects to the page list" do
      expect(response).to redirect_to form_pages_path(form.id)
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
      let(:expected_to_raise_error) { true }

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
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/#{selected_page.id}", headers, selected_page.to_json, 200
        mock.get "/api/v1/forms/1/pages/#{selected_page.id}/conditions/1", headers, condition.to_json, 200
      end

      if expected_to_raise_error
        allow(Pundit).to receive(:authorize).and_raise(Pundit::NotAuthorizedError)
      else
        allow(Pundit).to receive(:authorize).and_return(true)
      end

      delete_condition_form = Pages::DeleteConditionForm.new(form:, page: selected_page, record: condition, answer_value: "Yes", goto_page_id: 3)

      allow(delete_condition_form).to receive(:goto_page_question_text).and_return("What is your name?")

      allow(Pages::DeleteConditionForm).to receive(:new).and_return(delete_condition_form)

      get delete_condition_path(form_id: 1, page_id: selected_page.id, condition_id: condition.id)
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end

    it "renders the delete condition page template" do
      expect(response).to render_template("pages/conditions/delete")
    end

    context "when user should not be allowed to add routes to pages" do
      let(:expected_to_raise_error) { true }

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
    let(:confirm_deletion) { "true" }
    let(:delete_bool) { true }

    before do
      selected_page.routing_conditions = [condition]
      selected_page.position = 1
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1", headers, form.to_json, 200
        mock.get "/api/v1/forms/1/pages", headers, pages.to_json, 200
        mock.get "/api/v1/forms/1/pages/#{selected_page.id}", headers, selected_page.to_json, 200
        mock.get "/api/v1/forms/1/pages/#{selected_page.id}/conditions/1", headers, condition.to_json, 200
        mock.delete "/api/v1/forms/1/pages/#{selected_page.id}/conditions/1", headers, nil, 204
      end

      if expected_to_raise_error
        allow(Pundit).to receive(:authorize).and_raise(Pundit::NotAuthorizedError)
      else
        allow(Pundit).to receive(:authorize).and_return(true)
      end

      delete_condition_form = Pages::DeleteConditionForm.new(form:, page: selected_page, record: condition, answer_value: "Wales", goto_page_id: 3, confirm_deletion:)

      allow(delete_condition_form).to receive(:goto_page_question_text).and_return("What is your name?")

      allow(delete_condition_form).to receive(:delete).and_return(delete_bool)

      allow(Pages::DeleteConditionForm).to receive(:new).and_return(delete_condition_form)

      delete destroy_condition_path(form_id: form.id,
                                    page_id: selected_page.id,
                                    condition_id: condition.id,
                                    params: { pages_delete_condition_form: { confirm_deletion:, goto_page_id: 3, answer_value: "Wales" } })
    end

    it "Reads the form from the API" do
      expect(form).to have_been_read
    end

    it "redirects to the page list" do
      expect(response).to redirect_to form_pages_path(form.id, selected_page.id)
    end

    it "displays success message" do
      follow_redirect!
      expect(response.body).to include(I18n.t("banner.success.route_deleted", question_position: 1))
    end

    context "when confirm deletion is false" do
      let(:confirm_deletion) { "false" }

      it "redirects to edit the condition" do
        expect(response).to redirect_to edit_condition_path(form.id, selected_page.id, condition.id)
      end
    end

    context "when the destroy fails" do
      let(:delete_bool) { false }

      it "return 422 error code" do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when form submit fails" do
      let(:delete_bool) { false }
      let(:confirm_deletion) { nil }

      it "return 422 error code" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "renders the delete page" do
        expect(response).to render_template("pages/conditions/delete")
      end
    end

    context "when user should not be allowed to add routes to pages" do
      let(:expected_to_raise_error) { true }

      it "Renders the forbidden page" do
        expect(response).to render_template("errors/forbidden")
      end

      it "Returns a 403 status" do
        expect(response.status).to eq(403)
      end
    end
  end
end
