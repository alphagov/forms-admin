require "rails_helper"

RSpec.describe GroupPolicy do
  subject(:policy) { described_class.new(user, group) }

  let(:organisation) { create :organisation, slug: "an organisation" }
  let(:user) { create :editor_user, organisation: }
  let(:group) { build :group, organisation: }

  context "when user is super_admin" do
    let(:user) { build :super_admin_user }

    it "permits all actions" do
      expect(policy).to permit_all_actions
    end

    it "scope resolves to all groups" do
      expect(GroupPolicy::Scope.new(user, Group).resolve).to eq(Group.all)
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

      it "permits new and create only" do
        expect(policy).to permit_only_actions(%i[new create])
      end
    end

    it "scope resolves to groups user organisation admin for" do
      expect(GroupPolicy::Scope.new(user, Group).resolve).to eq(Group.for_organisation(user.organisation))
    end
  end

  context "when user is editor" do
    it "permits new and create only" do
      expect(policy).to permit_only_actions(%i[new create])
    end

    context "and user belongs to group as an editor" do
      before do
        create :membership, user:, group:, role: :editor
      end

      it "permits group creation, viewing, and editing" do
        expect(policy).to permit_only_actions(%i[show new create])
      end

      it "does not allow add_editor, rename or upgrade" do
        expect(policy).to forbid_only_actions(%i[add_editor edit update upgrade])
      end
    end

    it "scope resolves to only group user is a member of" do
      expect(GroupPolicy::Scope.new(user, Group).resolve).to eq(Group.for_user(user))
    end

    context "and user belongs to group as a group admin" do
      before do
        create :membership, user:, group:, role: :group_admin
      end

      it "allows view, list, modify group and add_editor" do
        expect(policy).to permit_only_actions(%i[show new edit create update add_editor])
      end
    end
  end
end
