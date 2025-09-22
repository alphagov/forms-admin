require "rails_helper"

RSpec.describe Forms::ArchivedController, type: :request do
  let(:form) { create(:form, :archived) }
  let(:id) { form.id }

  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)
    login_as_standard_user
  end

  describe "#show_form" do
    before do
      get archived_form_path(id)
    end

    it "renders the show archived form template" do
      expect(response).to render_template(:show_form)
    end

    context "when the form is archive_with_draft" do
      let(:form) { create(:form, :archived_with_draft) }

      it "renders the show archived form template" do
        expect(response).to render_template(:show_form)
      end
    end

    context "when the form is live" do
      let(:form) { create(:form, :live) }

      it "redirects to the live form page" do
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(live_form_path(form))
      end
    end

    context "when the form is draft" do
      let(:form) { create(:form) }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "#show_pages" do
    before do
      get archived_form_pages_path(id)
    end

    it "renders the show archived form pages template" do
      expect(response).to render_template(:show_pages)
    end

    context "when the form is archive_with_draft" do
      let(:form) { create(:form, :archived_with_draft) }

      it "renders the show archived form pages template" do
        expect(response).to render_template(:show_pages)
      end
    end

    context "when the form is live" do
      let(:form) { create(:form, :live) }

      it "redirects to the live form pages page" do
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(live_form_pages_path(form))
      end
    end

    context "when the form is draft" do
      let(:form) { create(:form) }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
