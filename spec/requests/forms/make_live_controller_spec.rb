require "rails_helper"

RSpec.describe Forms::MakeLiveController, type: :request do
  let(:user) { build :user }
  let(:id) { 2 }
  let(:form) { build(:form, :ready_for_live, id:) }

  let(:updated_form) do
    build(:form,
          :live,
          id: 2,
          name: form.name,
          form_slug: form.form_slug,
          submission_email: form.submission_email,
          privacy_policy_url: form.privacy_policy_url,
          support_email: form.support_email,
          pages: form.pages)
  end

  let(:form_params) { nil }

  let(:group_role) { :group_admin }
  let(:group) { create(:group, organisation: user.organisation, status: :active) }

  describe "#new" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.put "/api/v1/forms/2", post_headers
        mock.get "/api/v1/forms/2", headers, form.to_json, 200
      end

      ActiveResourceMock.mock_resource(form,
                                       {
                                         read: { response: form, status: 200 },
                                         update: { response: updated_form, status: 200 },
                                       })

      Membership.create!(group_id: group.id, user:, added_by: user, role: group_role)
      GroupForm.create!(form_id: form.id, group_id: group.id)

      login_as user

      get make_live_path(form_id: 2)
    end

    it "reads the form from the API" do
      expect(form).to have_been_read
    end

    it "returns 200" do
      expect(response).to have_http_status(:ok)
    end

    context "when the form is being created for the first time" do
      it "renders make your form live" do
        expect(response).to render_template("make_your_form_live")
      end
    end

    context "when editing a draft of an existing live form" do
      let(:form) do
        build(:form,
              :live,
              id: 2)
      end

      it "reads the form from the API" do
        expect(form).to have_been_read
      end

      it "renders make your changes live" do
        expect(response).to render_template("make_your_changes_live")
      end
    end

    context "when editing a draft of an archived form" do
      let(:form) do
        build(:form,
              :archived_with_draft,
              id: 2)
      end

      it "reads the form from the API" do
        expect(form).to have_been_read
      end

      it "renders make your changes live" do
        expect(response).to render_template("make_archived_draft_live")
      end
    end

    context "when current user is not a group admin" do
      let(:group_role) { :editor }

      it "is forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "#create" do
    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.post "/api/v1/forms/2/make-live", post_headers
        mock.get "/api/v1/forms/2", headers, form.to_json, 200
        mock.get "/api/v1/forms/2/live", headers, form.to_json, 200
      end

      Membership.create!(group_id: group.id, user:, added_by: user, role: group_role)
      GroupForm.create!(form_id: form.id, group_id: group.id)

      login_as user

      post(make_live_path(form_id: 2), params: form_params)
    end

    context "when making a form live" do
      let(:form_params) { { forms_make_live_input: { confirm: :yes, form: } } }

      it "reads the form from the API" do
        expect(form).to have_been_read
      end

      it "makes form live on the API" do
        make_live_post = ActiveResource::Request.new(:post, "/api/v1/forms/2/make-live", {}, post_headers)
        expect(ActiveResource::HttpMock.requests).to include make_live_post
      end

      it "renders the confirmation page" do
        expect(response).to render_template(:confirmation)
      end

      context "and that form has not been made live before" do
        it "has the page title 'Your form is live'" do
          expect(response.body).to include "Your form is live"
        end
      end

      context "and that form has already been made live before" do
        let(:form) do
          build(:form,
                :live,
                id: 2)
        end

        it "has the page title 'Your changes are live'" do
          expect(response.body).to include "Your changes are live"
        end
      end
    end

    context "when deciding not to make a form live" do
      let(:form_params) { { forms_make_live_input: { confirm: :no } } }

      it "reads the form from the API" do
        expect(form).to have_been_read
      end

      it "does not update the form on the API" do
        expect(form).not_to have_been_updated
      end

      it "redirects you to the form page" do
        expect(response).to redirect_to(form_path(2))
      end
    end

    context "when all tasks are not complete" do
      let(:form) { build(:form, :missing_pages, id:) }
      let(:form_params) { { forms_make_live_input: { confirm: "yes", form: } } }

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not update the form on the API" do
        expect(form).not_to have_been_updated
      end

      it "re-renders the page with an error" do
        expect(response).to render_template("make_your_form_live")
        expect(response.body).to include("You cannot make your form live because you have not finished adding questions.")
      end
    end

    context "when current user is not a group admin" do
      let(:group_role) { :editor }

      it "is forbidden" do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
