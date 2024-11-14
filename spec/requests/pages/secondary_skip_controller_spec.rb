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
  end
end
