require "rails_helper"

RSpec.describe Forms::WelshTranslationController, type: :request do
  let(:form) { create(:form) }
  let(:id) { form.id }

  let(:current_user) { standard_user }
  let(:group) { create(:group, organisation: standard_user.organisation, welsh_enabled: false) }

  before do
    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)

    login_as current_user
  end

  describe "#new" do
    before do
      get welsh_translation_path(id)
    end

    it "returns 200" do
      expect(response).to have_http_status(:ok)
    end

    it "renders the template" do
      expect(response).to render_template(:new)
    end
  end
end
