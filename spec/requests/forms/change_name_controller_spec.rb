require "rails_helper"

RSpec.describe Forms::ChangeNameController, type: :request do
  let(:form) { build(:form, id: 2, name: "Form name", creator_id: 123) }
  let(:organisation) { build :organisation, id: 1, slug: "test-org" }
  let(:user) { build :user, id: 1, organisation: }
  let(:group) { create(:group, organisation: user.organisation) }

  before do
    allow(FormRepository).to receive_messages(find: form, create!: form, save!: form)

    Membership.create!(group_id: group.id, user:, added_by: user)
    GroupForm.create!(form_id: 2, group_id: group.id)
    login_as user
  end

  describe "#edit" do
    before do
      get change_form_name_path(form_id: 2)
    end

    it "fetches the form" do
      expect(FormRepository).to have_received(:find)
    end
  end

  describe "#update" do
    it "renames form" do
      post change_form_name_path(form_id: 2), params: { forms_name_input: { name: "new_form_name", creator_id: 123 } }

      expect(FormRepository).to have_received(:save!)
      expect(response).to redirect_to(form_path(form_id: 2))
    end
  end
end
