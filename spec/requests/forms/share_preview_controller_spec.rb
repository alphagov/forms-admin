require "rails_helper"

RSpec.describe Forms::SharePreviewController, type: :request do
  let(:form) { create(:form, share_preview_completed: false) }
  let(:id) { form.id }

  let(:current_user) { standard_user }
  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)

    login_as current_user
  end

  describe "#new" do
    before do
      allow(FormRepository).to receive(:find).and_return(form)

      get share_preview_path(id)
    end

    it "reads the form" do
      expect(FormRepository).to have_received(:find)
    end

    it "returns 200" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the template" do
      expect(response).to render_template(:new)
    end

    context "when the user is not authorized" do
      let(:current_user) { build :user }

      it "returns 403" do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "#create" do
    let(:mark_complete) { "true" }

    before do
      allow(FormRepository).to receive_messages(find: form, save!: form)

      post share_preview_create_path(id), params: { forms_share_preview_input: { form:, mark_complete: } }
    end

    it "reads the form" do
      expect(FormRepository).to have_received(:find)
    end

    context "when 'Yes' is selected" do
      let(:updated_form) do
        form.tap do |f|
          f.share_preview_completed = "true"
        end
      end

      it "updates the form" do
        expect(FormRepository).to have_received(:save!)
      end

      it "redirects to the form" do
        expect(response).to redirect_to(form_path(id))
      end

      it "displays a success banner" do
        expect(flash[:success]).to eq(I18n.t("banner.success.form.share_preview_completed"))
      end
    end

    context "when 'No' is selected" do
      let(:mark_complete) { "false" }
      let(:updated_form) do
        form.tap do |f|
          f.share_preview_completed = "false"
        end
      end

      it "updates the form" do
        expect(FormRepository).to have_received(:save!)
      end

      it "redirects to the form" do
        expect(response).to redirect_to(form_path(id))
      end

      it "does not display a success banner" do
        expect(flash).to be_empty
      end
    end

    context "when no value is selected" do
      let(:mark_complete) { "" }

      it "does not update the form" do
        expect(FormRepository).not_to have_received(:save!)
      end

      it "returns an 422" do
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "re-renders the page with an error" do
        expect(response).to render_template(:new)
        expect(response.body).to include("You must choose an option")
      end
    end

    context "when the user is not authorized" do
      let(:current_user) { build :user }

      it "returns 403" do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
