require "rails_helper"

describe Pages::RoutesController, type: :request do
  let(:form) { build :form, :ready_for_routing, id: 1 }
  let(:pages) { form.pages }
  let(:page) do
    pages.first.tap do |first_page|
      first_page.id = 101
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

  let(:group) { create(:group, organisation: standard_user.organisation) }
  let(:user) { standard_user }

  before do
    allow(FormRepository).to receive(:find).and_return(form)
    allow(PageRepository).to receive(:find).and_return(page)

    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as user
  end

  describe "#show" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/1/pages", headers, pages.to_json, 200
      end

      allow(PageRepository).to receive(:find).with(page_id: "101", form_id: 1).and_return(selected_page)

      get show_routes_path(form_id: form.id, page_id: selected_page.id)
    end

    it "Reads the form" do
      expect(FormRepository).to have_received(:find)
    end

    it "renders the routing page template" do
      expect(response).to render_template("pages/routes/show")
    end
  end

  describe "#delete" do
    before do
      allow(FormRepository).to receive(:find).and_return(form)
      allow(PageRepository).to receive(:find).with(page_id: "101", form_id: 1).and_return(selected_page)

      get delete_routes_path(form_id: form.id, page_id: selected_page.id)
    end

    it "renders the delete confirmation for routes template" do
      expect(response).to have_http_status(:ok)
      expect(response).to render_template("pages/routes/delete")
    end
  end

  describe "#destroy" do
    let(:condition) { build :condition, routing_page_id: selected_page.id, check_page_id: selected_page.id, goto_page_id: pages.last.id, answer_value: "Option 1" }
    let(:secondary_skip_page) { form.pages[2] }
    let(:secondary_skip) { build :condition, routing_page_id: secondary_skip_page.id, check_page_id: selected_page.id, goto_page_id: pages[3].id }

    before do
      allow(FormRepository).to receive(:find).and_return(form)
      allow(PageRepository).to receive(:find).with(page_id: "101", form_id: 1).and_return(selected_page)
      allow(ConditionRepository).to receive(:find).and_return(condition)
      allow(ConditionRepository).to receive(:destroy)

      selected_page.routing_conditions = [condition]
      secondary_skip_page.routing_conditions = [secondary_skip]
    end

    context "when confirmed" do
      it "redirects to page list" do
        delete destroy_routes_path(form_id: form.id, page_id: selected_page.id, pages_routes_delete_confirmation_input: { confirm: "yes" })
        expect(response).to redirect_to form_pages_path(form_id: form.id)
      end

      it "calls destroy on conditions" do
        expect(ConditionRepository).to receive(:destroy).with(have_attributes(id: condition.id))
        expect(ConditionRepository).to receive(:destroy).with(have_attributes(id: secondary_skip.id))
        delete destroy_routes_path(form_id: form.id, page_id: selected_page.id, pages_routes_delete_confirmation_input: { confirm: "yes" })
      end
    end

    context "when given invalid params" do
      it "renders the delete page" do
        delete destroy_routes_path(form_id: form.id, page_id: selected_page.id, pages_routes_delete_confirmation_input: { confirm: nil })

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template("pages/routes/delete")
      end
    end

    context "when not confirmed" do
      it "redirects to routes page" do
        delete destroy_routes_path(form_id: form.id, page_id: selected_page.id, pages_routes_delete_confirmation_input: { confirm: "no" })
        expect(response).to redirect_to show_routes_path(form_id: form.id, page_id: selected_page.id)
      end

      it "does no call destroy on conditions" do
        expect(ConditionRepository).not_to receive(:destroy)
        delete destroy_routes_path(form_id: form.id, page_id: selected_page.id, pages_routes_delete_confirmation_input: { confirm: "no" })
      end
    end
  end
end
