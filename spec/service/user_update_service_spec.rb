require "rails_helper"

describe UserUpdateService do
  subject(:user_update_service) do
    described_class.new(user, params)
  end

  describe "#update_user" do
    let(:user) { build :user }
    let(:params) { {} }

    it "returns the value of user.update" do
      allow(user).to receive(:update).and_return(true)
      expect(user_update_service.update_user).to be true
    end

    it "calls remove_membership if user is updated" do
      allow(user).to receive(:update).and_return(true)
      allow(Membership).to receive(:destroy_invalid_organisation_memberships)
      user_update_service.update_user
      expect(Membership).to have_received(:destroy_invalid_organisation_memberships).with(user)
    end

    context "when user is not updated" do
      before do
        allow(user).to receive(:update).and_return(false)
      end

      it "does not run add_organisation_to_user_forms if user is not updated" do
        allow(Form).to receive(:update_organisation_for_creator)
        user_update_service.update_user
        expect(Form).not_to have_received(:update_organisation_for_creator)
      end

      it "does not run add_organisation_to_user_mou if user is not updated" do
        allow(MouSignature).to receive(:add_mou_signature_organisation)
        user_update_service.update_user
        expect(MouSignature).not_to have_received(:add_mou_signature_organisation)
      end

      it "does not call remove_membership if user is not updated" do
        allow(Membership).to receive(:destroy_invalid_organisation_memberships)
        user_update_service.update_user
        expect(Membership).not_to have_received(:destroy_invalid_organisation_memberships).with(user)
      end
    end

    context "when changing user role" do
      let(:user) { create :user, :with_trial_role, organisation: nil }
      let(:params) { { role: :editor } }

      before do
        allow(Form).to receive(:update_organisation_for_creator)
        allow(MouSignature).to receive(:add_mou_signature_organisation)

        user_update_service.update_user
      end

      context "when the user is a trial user changing to editor" do
        let(:organisation) { create(:organisation) }
        let(:params) { { role: "editor", name: "name required", organisation: } }

        it "updates the user's params" do
          expect(user.role).to eq("editor")
        end

        it "does not call update_organisation_for_creator" do
          expect(Form).not_to have_received(:update_organisation_for_creator).with(user.id, user.organisation_id)
        end
      end

      context "when the user is a super_admin changing to editor" do
        let(:user) { create :super_admin_user }
        let(:params) { { role: :editor } }

        it "updates the user's params" do
          expect(user).to be_editor
        end

        it "does not call update_organisation_for_creator" do
          expect(Form).not_to have_received(:update_organisation_for_creator).with(user.id, user.organisation_id)
        end
      end

      context "when the user is a given an organisation" do
        let(:params) { { organisation: build(:organisation) } }

        it "calls add_mou_signature_organisation on MouSignature" do
          expect(MouSignature).to have_received(:add_mou_signature_organisation).with(user)
        end
      end

      context "when a user is not given an organisation" do
        let(:params) { { name: "blank_name" } }

        it "does not call add_mou_signature_organisation on MouSignature" do
          expect(MouSignature).not_to have_received(:add_mou_signature_organisation).with(user)
        end
      end
    end
  end
end
