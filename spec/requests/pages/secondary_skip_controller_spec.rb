require "rails_helper"

RSpec.describe Pages::SecondarySkipController, type: :request do
  let(:form) { build :form, id: 2, pages: }
  let(:pages) do
    pages = build_list(:page, 5).each_with_index do |page, index|
      page.id = index + 1
    end

    pages.first.answer_settings =
      DataStruct.new(
        only_one_option: true,
        selection_options: [
          OpenStruct.new(attributes: { name: "Option 1" }),
          OpenStruct.new(attributes: { name: "Option 2" }),
        ],
      )

    pages.first.routing_conditions = [
      build(:condition, id: 1, routing_page_id: pages.first.id, check_page_id: pages.first.id, answer_value: "Option 1", goto_page_id: pages[2].id, skip_to_end: false),
    ]

    pages
  end

  let(:group) { create(:group, organisation: standard_user.organisation) }

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

  context "when the branch_routing feature is not enabled", feature_branch_routing: false do
    describe "#new" do
      it "returns a 404" do
        get new_secondary_skip_path(form_id: 2, page_id: 1)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  context "when the branch_routing feature is enabled", :feature_branch_routing do
    describe "#new" do
      it "returns 200" do
        get new_secondary_skip_path(form_id: 2, page_id: 1)
        expect(response).to have_http_status(:success)
      end
    end

    context "when no condition exists on the page" do
      let(:pages) do
        build_list(:page, 5).each_with_index do |page, index|
          page.id = index + 1
        end
      end

      it "redirects to the page list" do
        get new_secondary_skip_path(form_id: 2, page_id: 1)
        expect(response).to redirect_to(form_pages_path(form.id))
      end
    end

    context "when a secondary skip condition already exists on the page" do
      let(:existing_secondary_skip) do
        build(
          :condition,
          id: 2,
          routing_page_id: pages[2].id,
          check_page_id: pages[0].id,
          goto_page_id: pages[4].id,
          secondary_skip: true,
        )
      end

      before do
        pages[2].routing_conditions = [existing_secondary_skip]

        ActiveResource::HttpMock.respond_to do |mock|
          mock.get "/api/v1/forms/2", headers, form.to_json, 200
          mock.get "/api/v1/forms/2/pages", headers, pages.to_json, 200
          mock.get "/api/v1/forms/2/pages/1", headers, pages.first.to_json, 200
        end
      end

      it "redirects to the show routes page" do
        get new_secondary_skip_path(form_id: 2, page_id: 1)
        expect(response).to redirect_to(show_routes_path(form_id: 2, page_id: 1))
      end
    end
  end

  describe "#create" do
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

    context "when the branch_routing feature is not enabled", feature_branch_routing: false do
      it "returns a 404" do
        post create_secondary_skip_path(form_id: 2, page_id: 1), params: valid_params
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the branch_routing feature is enabled", :feature_branch_routing do
      context "when the submission is successful" do
        before do
          ActiveResource::HttpMock.respond_to(false) do |mock|
            mock.post "/api/v1/forms/2/pages/3/conditions", post_headers, {}.to_json, 200
          end
        end

        it "redirects to the show routes page" do
          post create_secondary_skip_path(form_id: 2, page_id: 1), params: valid_params
          expect(response).to redirect_to(show_routes_path(form_id: 2, page_id: 1))
        end
      end

      context "when no condition exists on the page" do
        let(:pages) do
          build_list(:page, 5).each_with_index do |page, index|
            page.id = index + 1
          end
        end

        it "redirects to the page list" do
          post create_secondary_skip_path(form_id: 2, page_id: 1), params: valid_params
          expect(response).to redirect_to(form_pages_path(form.id))
        end
      end

      context "when a secondary skip condition already exists on the page" do
        let(:existing_secondary_skip) do
          build(
            :condition,
            id: 2,
            routing_page_id: pages[2].id,
            check_page_id: pages[0].id,
            goto_page_id: pages[4].id,
            secondary_skip: true,
          )
        end

        before do
          pages[2].routing_conditions = [existing_secondary_skip]

          ActiveResource::HttpMock.respond_to do |mock|
            mock.get "/api/v1/forms/2", headers, form.to_json, 200
            mock.get "/api/v1/forms/2/pages", headers, pages.to_json, 200
            mock.get "/api/v1/forms/2/pages/1", headers, pages.first.to_json, 200
          end
        end

        it "redirects to the show routes page" do
          post create_secondary_skip_path(form_id: 2, page_id: 1), params: valid_params
          expect(response).to redirect_to(show_routes_path(form_id: 2, page_id: 1))
        end
      end

      context "when the submission fails" do
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
          post create_secondary_skip_path(form_id: 2, page_id: pages.first.id), params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template("pages/secondary_skip/new")
        end
      end
    end
  end

  describe "#edit" do
    let(:condition) do
      build(:condition, id: 2, check_page_id: 1, routing_page_id: pages[2].id, goto_page_id: pages[4].id)
    end

    before do
      pages[2].routing_conditions = [condition]

      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/2", headers, form.to_json, 200
        mock.get "/api/v1/forms/2/pages", headers, pages.to_json, 200
        mock.get "/api/v1/forms/2/pages/1", headers, pages.first.to_json, 200
      end
    end

    context "when the branch_routing feature is not enabled", feature_branch_routing: false do
      it "returns a 404" do
        get edit_secondary_skip_path(form_id: 2, page_id: 1)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the branch_routing feature is enabled", :feature_branch_routing do
      it "returns 200" do
        get edit_secondary_skip_path(form_id: 2, page_id: 1)
        expect(response).to have_http_status(:success)
      end

      it "renders the edit template" do
        get edit_secondary_skip_path(form_id: 2, page_id: 1)
        expect(response).to render_template("pages/secondary_skip/edit")
      end

      context "when no condition exists on the page" do
        let(:pages) do
          build_list(:page, 5).each_with_index do |page, index|
            page.id = index + 1
          end
        end

        it "redirects to the page list" do
          get edit_secondary_skip_path(form_id: 2, page_id: 1)
          expect(response).to redirect_to(form_pages_path(form.id))
        end
      end

      context "when no secondary_skip exists on the page" do
        before do
          pages[2].routing_conditions = []

          ActiveResource::HttpMock.respond_to do |mock|
            mock.get "/api/v1/forms/2", headers, form.to_json, 200
            mock.get "/api/v1/forms/2/pages", headers, pages.to_json, 200
            mock.get "/api/v1/forms/2/pages/1", headers, pages.first.to_json, 200
          end
        end

        it "redirects to the page list" do
          get edit_secondary_skip_path(form_id: 2, page_id: 1)
          expect(response).to redirect_to(show_routes_path(form_id: 2, page_id: 1))
        end
      end
    end
  end

  describe "#update" do
    let(:condition) do
      build(
        :condition,
        id: 2,
        check_page_id: 1,
        routing_page_id: pages[2].id,
        goto_page_id: pages[4].id,
      )
    end

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
      pages[2].routing_conditions = [condition]

      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms/2", headers, form.to_json, 200
        mock.get "/api/v1/forms/2/pages", headers, pages.to_json, 200
        mock.get "/api/v1/forms/2/pages/1", headers, pages.first.to_json, 200
      end
    end

    context "when the branch_routing feature is not enabled", feature_branch_routing: false do
      it "returns a 404" do
        patch update_secondary_skip_path(form_id: 2, page_id: 1), params: valid_params
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the branch_routing feature is enabled", :feature_branch_routing do
      context "when the submission is successful without changing the routing_page_id" do
        before do
          ActiveResource::HttpMock.respond_to(false) do |mock|
            mock.put "/api/v1/forms/2/pages/3/conditions/2", post_headers, {}.to_json, 200
          end
        end

        it "redirects to the show routes page" do
          post update_secondary_skip_path(form_id: 2, page_id: 1), params: valid_params
          expect(response).to redirect_to(show_routes_path(form_id: 2, page_id: 1))
        end
      end

      context "when no condition exists on the page" do
        let(:pages) do
          build_list(:page, 5).each_with_index do |page, index|
            page.id = index + 1
          end
        end

        it "redirects to the page list" do
          post update_secondary_skip_path(form_id: 2, page_id: 1), params: valid_params
          expect(response).to redirect_to(form_pages_path(form.id))
        end
      end

      context "when no secondary_skip exists on the page" do
        before do
          pages[2].routing_conditions = []

          ActiveResource::HttpMock.respond_to do |mock|
            mock.get "/api/v1/forms/2", headers, form.to_json, 200
            mock.get "/api/v1/forms/2/pages", headers, pages.to_json, 200
            mock.get "/api/v1/forms/2/pages/1", headers, pages.first.to_json, 200
          end
        end

        it "redirects to the page list" do
          post update_secondary_skip_path(form_id: 2, page_id: 1), params: valid_params
          expect(response).to redirect_to(show_routes_path(form_id: 2, page_id: 1))
        end
      end

      context "when the submission is successful and changes the routing_page_id" do
        let(:valid_params) do
          {
            form_id: "2",
            page_id: "1",
            pages_secondary_skip_input: {
              routing_page_id: "2",
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
          post update_secondary_skip_path(form_id: 2, page_id: 1), params: valid_params
          expect(response).to redirect_to(show_routes_path(form_id: 2, page_id: 1))
        end
      end

      context "when the submission fails" do
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
          post update_secondary_skip_path(form_id: 2, page_id: 1), params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template("pages/secondary_skip/edit")
        end
      end
    end
  end
end
