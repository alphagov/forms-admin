require "rails_helper"

RSpec.describe Pages::SecondarySkipController, type: :request do
  let(:form) { build :form, id: 2, pages: }

  let(:group) { create(:group, organisation: standard_user.organisation) }

  RSpec.shared_examples "feature flag protected endpoint" do |action|
    context "when the branch_routing feature is disabled" do
      it "returns 404", feature_branch_routing: false do
        send(action)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  RSpec.shared_examples "requires condition" do |action|
    let(:pages) { build_pages }

    it "redirects to the page list" do
      send(action)
      expect(response).to redirect_to(form_pages_path(form.id))
    end
  end

  before do
    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as_standard_user

    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms/2", headers, form.to_json, 200
      mock.get "/api/v1/forms/2/pages", headers, pages.to_json, 200
      mock.get "/api/v1/forms/2/pages/1", headers, pages.first.to_json, 200
    end
  end

  describe "#new" do
    subject(:get_new) { get new_secondary_skip_path(form_id: 2, page_id: 1) }

    let(:pages) { build_pages_with_skip_condition }

    it_behaves_like "feature flag protected endpoint", :subject

    context "when the branch_routing feature is enabled", :feature_branch_routing do
      it_behaves_like "requires condition", :subject

      it "returns 200" do
        get_new
        expect(response).to have_http_status(:success)
      end

      context "when a secondary skip condition already exists on the page" do
        let(:pages) { build_pages_with_existing_secondary_skip }

        it "redirects to the show routes page" do
          get_new
          expect(response).to redirect_to(show_routes_path(form_id: 2, page_id: 1))
        end
      end
    end
  end

  describe "#create" do
    subject(:post_create) { post create_secondary_skip_path(form_id: 2, page_id: 1), params: valid_params }

    let(:pages) { build_pages_with_skip_condition }

    let(:valid_params) do
      {
        form_id: "2",
        page_id: "1",
        pages_secondary_skip_input: {
          routing_page_id: "3",
          goto_page_id: "5",
        },
      }
    end

    it_behaves_like "feature flag protected endpoint", :subject

    context "when the branch_routing feature is enabled", :feature_branch_routing do
      it_behaves_like "requires condition", :subject

      context "when the submission is successful" do
        before do
          ActiveResource::HttpMock.respond_to(false) do |mock|
            mock.post "/api/v1/forms/2/pages/3/conditions", post_headers, {}.to_json, 200
          end
        end

        it "redirects to the show routes page" do
          post_create
          expect(response).to redirect_to(show_routes_path(form_id: 2, page_id: 1))
        end
      end

      context "when a secondary skip condition already exists on the page" do
        let(:pages) { build_pages_with_existing_secondary_skip }

        it "redirects to the show routes page" do
          post_create
          expect(response).to redirect_to(show_routes_path(form_id: 2, page_id: 1))
        end
      end

      context "when the submission fails" do
        subject(:post_create) { post create_secondary_skip_path(form_id: 2, page_id: 1), params: invalid_params }

        let(:invalid_params) do
          {
            form_id: "2",
            page_id: "1",
            pages_secondary_skip_input: {
              routing_page_id: "3",
              goto_page_id: "3",
            },
          }
        end

        it "renders the new template" do
          post_create
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template("pages/secondary_skip/new")
        end
      end
    end
  end

  describe "#edit" do
    subject(:get_edit) { get edit_secondary_skip_path(form_id: 2, page_id: 1) }

    let(:pages) { build_pages_with_existing_secondary_skip }

    it_behaves_like "feature flag protected endpoint", :subject

    context "when the branch_routing feature is enabled", :feature_branch_routing do
      it_behaves_like "requires condition", :subject

      it "returns 200" do
        get_edit
        expect(response).to have_http_status(:success)
      end

      it "renders the edit template" do
        get_edit
        expect(response).to render_template("pages/secondary_skip/edit")
      end

      context "when no secondary_skip exists on the page" do
        let(:pages) { build_pages_with_skip_condition }

        it "redirects to the page list" do
          get_edit
          expect(response).to redirect_to(show_routes_path(form_id: 2, page_id: 1))
        end
      end
    end
  end

  describe "#update" do
    subject(:post_update) { post update_secondary_skip_path(form_id: 2, page_id: 1), params: valid_params }

    let(:pages) { build_pages_with_existing_secondary_skip }

    let(:valid_params) do
      {
        form_id: "2",
        page_id: "1",
        pages_secondary_skip_input: {
          routing_page_id: "3",
          goto_page_id: "5",
        },
      }
    end

    it_behaves_like "feature flag protected endpoint", :subject

    context "when the branch_routing feature is enabled", :feature_branch_routing do
      it_behaves_like "requires condition", :subject

      context "when the submission is successful without changing the routing_page_id" do
        before do
          ActiveResource::HttpMock.respond_to(false) do |mock|
            mock.put "/api/v1/forms/2/pages/3/conditions/2", post_headers, {}.to_json, 200
          end
        end

        it "redirects to the show routes page" do
          post_update
          expect(response).to redirect_to(show_routes_path(form_id: 2, page_id: 1))
        end
      end

      context "when no secondary_skip exists on the page" do
        let(:pages) { build_pages_with_skip_condition }

        it "redirects to the page list" do
          post_update
          expect(response).to redirect_to(show_routes_path(form_id: 2, page_id: 1))
        end
      end

      context "when the submission is successful and changes the routing_page_id" do
        let(:valid_params) do
          {
            form_id: "2",
            page_id: "1",
            pages_secondary_skip_input: {
              routing_page_id: "3",
              goto_page_id: "5",
            },
          }
        end

        before do
          ActiveResource::HttpMock.respond_to(false) do |mock|
            mock.delete "/api/v1/forms/2/pages/3/conditions/2", headers, {}.to_json, 200
            mock.post "/api/v1/forms/2/pages/2/conditions", post_headers, {}.to_json, 200
          end
        end

        it "redirects to the show routes page" do
          post_update
          expect(response).to redirect_to(show_routes_path(form_id: 2, page_id: 1))
        end
      end

      context "when the submission fails" do
        subject(:post_update) { post update_secondary_skip_path(form_id: 2, page_id: 1), params: invalid_params }

        let(:invalid_params) do
          {
            form_id: "2",
            page_id: "1",
            pages_secondary_skip_input: {
              routing_page_id: "3",
              goto_page_id: "3",
            },
          }
        end

        it "renders the edit template" do
          post_update
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template("pages/secondary_skip/edit")
        end
      end
    end
  end

  def build_pages
    build_list(:page, 5).each_with_index do |page, index|
      page.id = index + 1
    end
  end

  def build_pages_with_skip_condition
    build_pages.tap do |pages|
      pages[0] = build :page, :with_selections_settings, id: 1, routing_conditions: [
        build(:condition, id: 1, routing_page_id: pages.first.id, check_page_id: pages.first.id, answer_value: "Option 1", goto_page_id: pages[2].id, skip_to_end: false),
      ]
    end
  end

  def build_pages_with_existing_secondary_skip
    build_pages_with_skip_condition.tap do |pages|
      existing_secondary_skip = build(
        :condition,
        id: 2,
        routing_page_id: pages[1].id,
        check_page_id: pages[0].id,
        goto_page_id: pages[4].id,
        secondary_skip: true,
      )
      pages[1].routing_conditions = [existing_secondary_skip]
    end
  end

  def build_pages_with_two_skip_conditions
    build_pages.tap do |pages|
      pages[0] = build :page, :with_selections_settings, id: 1, routing_conditions: [
        build(:condition, id: 1, routing_page_id: pages.first.id, check_page_id: pages.first.id, answer_value: "Option 1", goto_page_id: pages[2].id, skip_to_end: false),
      ]

      first_secondary_skip = build(
        :condition,
        id: 2,
        routing_page_id: pages[1].id,
        check_page_id: pages[0].id,
        goto_page_id: pages[4].id,
        secondary_skip: true,
      )

      pages[1].routing_conditions = [first_secondary_skip]

      pages[5] = build :page, :with_selections_settings, id: 6, routing_conditions: [
        build(:condition, id: 3, routing_page_id: pages.first.id, check_page_id: pages.first.id, answer_value: "Option 1", goto_page_id: pages[7].id, skip_to_end: false),
      ]

      second_secondary_skip = build(
        :condition,
        id: 4,
        routing_page_id: pages[6].id,
        check_page_id: pages[5].id,
        goto_page_id: nil,
        skip_to_end: true,
      )

      pages[6].routing_conditions = [second_secondary_skip]
    end
  end
end
