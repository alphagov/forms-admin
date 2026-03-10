require "rails_helper"

RSpec.describe FormsController, type: :request do
  let(:form) { create(:form) }
  let(:group) { create(:group, organisation: standard_user.organisation) }
  let(:user) { standard_user }

  before do
    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)

    login_as user
  end

  describe "Showing an existing form" do
    describe "Given a live form" do
      let(:form) { create(:form, :live) }
      let(:params) { {} }

      before do
        get form_path(form.id, params)
      end

      it "renders the show template" do
        expect(response).to render_template("forms/show")
      end

      it "includes a task list" do
        expect(assigns[:task_list]).to be_truthy
      end
    end

    context "with a non-live form" do
      before do
        get form_path(form.id)
      end

      it "renders the show template" do
        expect(response).to render_template("forms/show")
      end
    end

    context "when user is not in same group as form" do
      let(:user) { build :user }

      before do
        get form_path(form.id)
      end

      it "Renders the forbidden page" do
        expect(response).to render_template("errors/forbidden")
      end

      it "Returns a 403 status" do
        expect(response.status).to eq(403)
      end
    end
  end

  describe "no form found" do
    before do
      get form_path(999)
    end

    it "Render the not found page" do
      expect(response.body).to include(I18n.t("not_found.title"))
    end

    it "returns 404" do
      expect(response.status).to eq(404)
    end
  end
end
