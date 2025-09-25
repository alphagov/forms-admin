require "rails_helper"

RSpec.describe Forms::MakeLiveController, type: :request do
  let(:user) { build :user }
  let(:form) { create(:form, :ready_for_live) }
  let(:id) { form.id }

  let(:updated_form) do
    build(:form,
          :live,
          id: form.id,
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
      Membership.create!(group_id: group.id, user:, added_by: user, role: group_role)
      GroupForm.create!(form_id: form.id, group_id: group.id)

      login_as user

      get make_live_path(form_id: form.id)
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
      let(:form) { create(:form, :live) }

      it "renders make your changes live" do
        expect(response).to render_template("make_your_changes_live")
      end
    end

    context "when editing a draft of an archived form" do
      let(:form) { create(:form, :archived_with_draft) }

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
      Membership.create!(group_id: group.id, user:, added_by: user, role: group_role)
      GroupForm.create!(form_id: form.id, group_id: group.id)

      login_as user
    end

    context "when making a form live" do
      let(:form_params) { { forms_make_live_input: { confirm: :yes, form: } } }

      it "makes the form live" do
        post(make_live_path(form_id: form.id), params: form_params)
        expect(form.reload.live?).to be true
      end

      it "renders the confirmation page" do
        post(make_live_path(form_id: form.id), params: form_params)
        expect(response).to render_template(:confirmation)
      end

      context "and that form has not been made live before" do
        it "has the page title 'Your form is live'" do
          post(make_live_path(form_id: form.id), params: form_params)
          expect(response.body).to include "Your form is live"
        end

        it "creates a FormDocument" do
          expect {
            post(make_live_path(form_id: form.id), params: form_params)
          }.to change(FormDocument, :count).by(1)
        end

        it "sets the FormDocument's live_at time to be equal to the form's updated_at time" do
          post(make_live_path(form_id: form.id), params: form_params)
          expect(FormDocument.find_by(form_id: form.id, tag: "live")["content"]["live_at"]).to eq form.reload.updated_at.strftime("%Y-%m-%dT%H:%M:%S.%6NZ")
        end
      end

      context "and that form has already been made live before" do
        context "and does not have draft changes" do
          let(:form) { create(:form, :live) }

          it "has the page title 'Your changes are live'" do
            post(make_live_path(form_id: form.id), params: form_params)
            expect(response.body).to include "Your changes are live"
          end

          it "does not change the live form document" do
            expect {
              post(make_live_path(form_id: form.id), params: form_params)
            }.not_to(change { form.reload.live_form_document.updated_at })
          end
        end

        context "and has draft changes" do
          let(:form) do
            form = create(:form, :live_with_draft)
            form.update!(name: "Form with changes")
            form
          end

          it "has the page title 'Your changes are live'" do
            post(make_live_path(form_id: form.id), params: form_params)
            expect(response.body).to include "Your changes are live"
          end

          it "updates the form document" do
            expect {
              post(make_live_path(form_id: form.id), params: form_params)
            }.to(change { form.reload.live_form_document.updated_at })
          end
        end
      end
    end

    context "when deciding not to make a form live" do
      let(:form_params) { { forms_make_live_input: { confirm: :no } } }

      before do
        post(make_live_path(form_id: form.id), params: form_params)
      end

      it "does not make the form live" do
        expect(form.reload.draft?).to be true
      end

      it "redirects you to the form page" do
        expect(response).to redirect_to(form_path(form.id))
      end
    end

    context "when all tasks are not complete" do
      let(:form) { create(:form, :missing_pages) }
      let(:form_params) { { forms_make_live_input: { confirm: "yes", form: } } }

      before do
        post(make_live_path(form_id: form.id), params: form_params)
      end

      it "returns 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "does not make the form live" do
        expect(form.reload.draft?).to be true
      end

      it "re-renders the page with an error" do
        expect(response).to render_template("make_your_form_live")
        expect(response.body).to include("You cannot make your form live because you have not finished adding questions.")
      end
    end

    context "when current user is not a group admin" do
      let(:group_role) { :editor }

      it "is forbidden" do
        post(make_live_path(form_id: form.id), params: form_params)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
