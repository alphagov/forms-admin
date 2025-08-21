require "rails_helper"

describe Pages::RoutesController, type: :request do
  let(:form) { create :form, :ready_for_routing }
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

  let(:group) { create(:group, organisation: standard_user.organisation) }
  let(:user) { standard_user }

  before do
    allow(FormRepository).to receive_messages(find: form, pages: pages)
    allow(PageRepository).to receive(:find).and_return(page)

    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as user
  end

  describe "#show" do
    before do
      allow(PageRepository).to receive(:find).with(page_id: page.id, form_id: form.id).and_return(page)

      get show_routes_path(form_id: form.id, page_id: page.id)
    end

    it "Reads the form" do
      expect(FormRepository).to have_received(:find)
    end

    it "renders the routing page template" do
      expect(response).to render_template("pages/routes/show")
    end

    context "when the page is at the end of the form" do
      let(:page) do
        pages.last.tap do |last_page|
          last_page.is_optional = false
          last_page.answer_type = "selection"
          last_page.answer_settings = DataStruct.new(
            only_one_option: true,
            selection_options: [OpenStruct.new(attributes: { name: "Option 1" }),
                                OpenStruct.new(attributes: { name: "Option 2" })],
          )
        end
      end

      it "renders the routing page template" do
        expect(response).to render_template("pages/routes/show")
      end
    end
  end

  describe "#delete" do
    before do
      allow(PageRepository).to receive(:find).with(page_id: page.id, form_id: form.id).and_return(page)

      get delete_routes_path(form_id: form.id, page_id: page.id)
    end

    it "renders the delete confirmation for routes template" do
      expect(response).to have_http_status(:ok)
      expect(response).to render_template("pages/routes/delete")
    end
  end

  describe "#destroy" do
    let(:condition) { create :condition, routing_page_id: page.id, check_page_id: page.id, goto_page_id: pages.last.id, answer_value: "Option 1" }
    let(:secondary_skip_page) { form.pages[2] }
    let!(:secondary_skip) { create :condition, routing_page_id: secondary_skip_page.id, check_page_id: page.id, goto_page_id: pages[3].id }

    before do
      allow(PageRepository).to receive(:find).with(page_id: page.id, form_id: form.id).and_return(page)
      allow(ConditionRepository).to receive(:find).and_return(condition)
      allow(ConditionRepository).to receive(:destroy)

      page.reload
      secondary_skip_page.reload
    end

    context "when confirmed" do
      it "redirects to page list" do
        delete destroy_routes_path(form_id: form.id, page_id: page.id, pages_routes_delete_confirmation_input: { confirm: "yes" })
        expect(response).to redirect_to form_pages_path(form_id: form.id)
      end

      it "calls destroy on conditions" do
        expect(ConditionRepository).to receive(:destroy).with(have_attributes(id: condition.id))
        expect(ConditionRepository).to receive(:destroy).with(have_attributes(id: secondary_skip.id))
        delete destroy_routes_path(form_id: form.id, page_id: page.id, pages_routes_delete_confirmation_input: { confirm: "yes" })
      end

      context "but one of the routes is already deleted" do
        before do
          # forms-api may choose to delete the secondary skip when the condition is deleted
          allow(ConditionRepository).to receive(:destroy).and_call_original
          ActiveResource::HttpMock.respond_to do |mock|
            mock.delete "/api/v1/forms/#{form.id}/pages/#{page.id}/conditions/#{condition.id}", delete_headers, nil, 204
            mock.delete "/api/v1/forms/#{form.id}/pages/#{secondary_skip_page.id}/conditions/#{secondary_skip.id}", delete_headers, nil, 404
          end
        end

        it "does not render an error page" do
          delete destroy_routes_path(form_id: form.id, page_id: page.id, pages_routes_delete_confirmation_input: { confirm: "yes" })
          expect(response).not_to be_client_error
        end
      end
    end

    context "when given invalid params" do
      it "renders the delete page" do
        delete destroy_routes_path(form_id: form.id, page_id: page.id, pages_routes_delete_confirmation_input: { confirm: nil })

        expect(response).to have_http_status(:unprocessable_content)
        expect(response).to render_template("pages/routes/delete")
      end
    end

    context "when not confirmed" do
      it "redirects to routes page" do
        delete destroy_routes_path(form_id: form.id, page_id: page.id, pages_routes_delete_confirmation_input: { confirm: "no" })
        expect(response).to redirect_to show_routes_path(form_id: form.id, page_id: page.id)
      end

      it "does no call destroy on conditions" do
        expect(ConditionRepository).not_to receive(:destroy)
        delete destroy_routes_path(form_id: form.id, page_id: page.id, pages_routes_delete_confirmation_input: { confirm: "no" })
      end
    end
  end
end
