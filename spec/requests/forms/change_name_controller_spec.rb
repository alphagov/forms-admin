require "rails_helper"

RSpec.describe Forms::ChangeNameController, type: :request do
  let(:form_response_data) do
    {
      id: 2,
      name: "Form name",
      creator_id: 123,
    }.to_json
  end

  let(:organisation) { build :organisation, id: 1, slug: "test-org" }
  let(:user) { build :user, id: 1, organisation: }
  let(:group) { create(:group, organisation: user.organisation) }

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms/2", headers, form_response_data, 200
      mock.post "/api/v1/forms", post_headers, { id: 2 }.to_json, 200
      mock.put "/api/v1/forms/2", post_headers
    end

    Membership.create!(group_id: group.id, user:, added_by: user)
    GroupForm.create!(form_id: 2, group_id: group.id)
    login_as user
  end

  describe "#edit" do
    before do
      get change_form_name_path(form_id: 2)
    end

    it "fetches the from from the API" do
      expected_request = ActiveResource::Request.new(:get, "/api/v1/forms/2", {}, headers)
      expect(ActiveResource::HttpMock.requests).to include expected_request
    end
  end

  describe "#update" do
    it "renames form" do
      post change_form_name_path(form_id: 2), params: { forms_name_input: { name: "new_form_name", creator_id: 123 } }
      expected_request = ActiveResource::Request.new(:put, "/api/v1/forms/2", { "id": 2, "name": "new_form_name", creator_id: 123 }.to_json, post_headers)
      expect(ActiveResource::HttpMock.requests).to include expected_request
      expect(ActiveResource::HttpMock.requests[1].body).to eq expected_request.body
      expect(response).to redirect_to(form_path(form_id: 2))
    end
  end
end
