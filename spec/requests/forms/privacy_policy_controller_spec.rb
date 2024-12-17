require "rails_helper"

RSpec.describe Forms::PrivacyPolicyController, type: :request do
  let(:form) do
    build(:form, :live, id: 2, privacy_policy_url: "https://www.example.com")
  end

  let(:updated_form) do
    new_form = form
    new_form.privacy_policy_url = "https://www.example.gov.uk/privacy-policy"
    new_form
  end

  let(:group) { create(:group, organisation: standard_user.organisation) }

  before do
    allow(FormRepository).to receive_messages(find: form, save!: updated_form)

    Membership.create!(group_id: group.id, user: standard_user, added_by: standard_user)
    GroupForm.create!(form_id: form.id, group_id: group.id)

    login_as_standard_user
  end

  describe "#new" do
    before do
      get privacy_policy_path(form_id: 2)
    end

    it "Reads the form" do
      expect(FormRepository).to have_received(:find)
    end
  end

  describe "#create" do
    before do
      post privacy_policy_path(form_id: 2), params: { forms_privacy_policy_input: { privacy_policy_url: "https://www.example.gov.uk/privacy-policy" } }
    end

    it "Reads the form" do
      expect(FormRepository).to have_received(:find)
    end

    it "Updates the form" do
      expect(FormRepository).to have_received(:save!)
    end

    it "Redirects you to the form overview page" do
      expect(response).to redirect_to(form_path(2))
    end
  end
end
