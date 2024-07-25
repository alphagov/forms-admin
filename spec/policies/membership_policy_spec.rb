require "rails_helper"

RSpec.describe MembershipPolicy do
  subject(:policy) { described_class.new(user, membership) }

  let(:organisation) { create :organisation, slug: "an organisation" }
  let(:user) { create :user, organisation: }
  let(:group) { build :group, organisation: }
  let(:membership) { build :membership, user:, group:, role: }
  let(:role) { :editor }

  context "when user is super_admin" do
    let(:user) { build :super_admin_user }

    it "permits all actions" do
      expect(policy).to permit_all_actions
    end
  end

  context "when user is organisation_admin" do
    let(:user) { build :organisation_admin_user, organisation: }

    context "and in the same organisation as the group" do
      it "permits all actions" do
        expect(policy).to permit_all_actions
      end
    end

    context "and not in the same organisation as the group" do
      let(:group) { build :group, organisation_id: user.organisation_id + 1 }

      it "forbids all actions" do
        expect(policy).to forbid_all_actions
      end
    end
  end

  context "when the user is a group admin" do
    before do
      create :membership, user:, group:, role: :group_admin
    end

    context "and the membership role is editor" do
      let(:role) { :editor }

      it "permits destroy" do
        expect(policy).to permit_only_actions(%i[destroy])
      end
    end

    context "and the membership role is group_admin" do
      let(:role) { :group_admin }

      it "forbids destroy" do
        expect(policy).to forbid_only_actions(%i[destroy update])
      end
    end
  end

  context "when the user is an editor" do
    it "forbids all actions" do
      expect(policy).to forbid_all_actions
    end
  end
end
