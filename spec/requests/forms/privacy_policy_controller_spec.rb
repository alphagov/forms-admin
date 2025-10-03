require "rails_helper"

RSpec.describe Forms::PrivacyPolicyController, type: :request do
  let(:form) do
    create(:form, :live, privacy_policy_url: "https://www.example.com")
  end
  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)

    login_as_standard_user
  end

  describe "#create" do
    let(:privacy_policy_url) { "https://www.example.gov.uk/privacy-policy" }
    let(:params) { { forms_privacy_policy_input: { privacy_policy_url: } } }

    it "Updates the form" do
      expect {
        post(privacy_policy_path(form_id: form.id), params:)
      }.to change { form.reload.privacy_policy_url }.to(privacy_policy_url)
    end

    it "Redirects you to the form overview page" do
      post(privacy_policy_path(form_id: form.id), params:)
      expect(response).to redirect_to(form_path(form.id))
    end
  end
end
