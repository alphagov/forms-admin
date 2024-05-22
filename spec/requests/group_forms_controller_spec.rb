require "rails_helper"

RSpec.describe "/groups/:group_id/forms", type: :request do
  let(:group) { create :group }
  let(:nonexistent_group) { "foobar" }

  let(:valid_attributes) do
    { name: "Test form" }
  end
  let(:invalid_attributes) do
    { name: "" }
  end

  before do
    create(:membership, user: editor_user, group:)
    login_as_editor_user
  end

  describe "GET /new" do
    before do
      get new_group_form_url(group)
    end

    it "renders a successful response" do
      expect(response).to have_http_status :ok
    end

    it "renders the change name form" do
      assert_select "form[action=?][method=?]", group_forms_path, :post do
        assert_select "input[name=?]", "forms_name_input[name]"
      end
    end

    it "has a back link to the group page" do
      rendered = Capybara.string(response.body)
      expect(rendered).to have_link "Back", href: group_path(group)
    end

    context "when the current user does not have access to the group" do
      it "denies access" do
        other_group = create :group

        get new_group_form_url(other_group)

        expect(response).to have_http_status :forbidden
      end
    end

    context "when the group does not exist" do
      it "renders a 404 not found response" do
        get new_group_form_url(nonexistent_group)

        expect(response).to have_http_status :not_found
      end
    end
  end

  describe "POST /" do
    context "with valid parameters" do
      let(:new_form_id) { 1 }

      before do
        ActiveResource::HttpMock.respond_to do |mock|
          mock.post "/api/v1/forms", post_headers, { id: new_form_id }.to_json, 200
        end
      end

      it "creates a new form" do
        post group_forms_url(group), params: { forms_name_input: valid_attributes }

        expected_request = ActiveResource::Request.new(:post, "/api/v1/forms", nil, post_headers)
        expect(ActiveResource::HttpMock.requests).to include expected_request
      end

      it "associates the new form with the group" do
        expect {
          post group_forms_url(group), params: { forms_name_input: valid_attributes }
        }.to change(GroupForm, :count).by(1)

        expect(GroupForm.last).to have_attributes(group_id: group.id, form_id: new_form_id)
      end

      it "redirects to the created form" do
        post group_forms_url(group), params: { forms_name_input: valid_attributes }
        expect(response).to redirect_to(form_url(new_form_id))
      end
    end

    context "with invalid parameters" do
      before do
        ActiveResource::HttpMock.reset! # not expecting any API calls
      end

      it "does not create a new form" do
        expect {
          post group_forms_url(group), params: { forms_name_input: invalid_attributes }
        }.to change(GroupForm, :count).by(0)

        expect(ActiveResource::HttpMock.requests).to be_empty
      end

      it "renders a response with 422 status" do
        post group_forms_url(group), params: { forms_name_input: invalid_attributes }
        expect(response).to have_http_status :unprocessable_entity
      end

      it "renders the change name form with an error" do
        post group_forms_url(group), params: { forms_name_input: invalid_attributes }

        expect(assigns[:name_input]).to be_truthy
        expect(response).to render_template("group_forms/new")
        expect(response).to render_template("input_objects/forms/_name_input")
        expect(response.body).to include I18n.t("error_summary.heading")
      end
    end

    context "when the current user does not have access to the group" do
      it "denies access" do
        other_group = create :group

        post group_forms_url(other_group), params: { forms_name_input: valid_attributes }

        expect(response).to have_http_status :forbidden
      end
    end

    context "when the group does not exist" do
      it "renders a 404 not found response" do
        post group_forms_url(nonexistent_group), params: { forms_name_input: valid_attributes }

        expect(response).to have_http_status :not_found
      end
    end
  end
end
