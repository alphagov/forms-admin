require "rails_helper"

RSpec.describe Forms::ChangeNameController, type: :request do
  let(:form) { create(:form, name: "Form name", creator_id: 123) }
  let(:organisation) { build :organisation, id: 1, slug: "test-org" }
  let(:user) { build :user, id: 1, organisation: }
  let(:group) { create(:group, organisation: user.organisation) }

  before do
    allow(FormRepository).to receive_messages(create!: form, save!: form)

    Membership.create!(group_id: group.id, user:, added_by: user)
    GroupForm.create!(form:, group_id: group.id)
    login_as user
  end

  describe "#update" do
    it "renames form" do
      post change_form_name_path(form_id: form.id), params: { forms_name_input: { name: "new_form_name", creator_id: 123 } }

      expect(FormRepository).to have_received(:save!)
      expect(response).to redirect_to(form_path(form_id: form.id))
    end
  end
end
