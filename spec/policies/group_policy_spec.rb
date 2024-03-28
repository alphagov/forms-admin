require "rails_helper"

RSpec.describe GroupPolicy do
  subject(:policy) { described_class.new(user, group) }

  let(:user) { build :editor_user }
  let(:group) { create :group, organisation_id: user.organisation_id }

  context "when user is super_admin" do
    let(:user) { build :super_admin_user }

    it { is_expected.to permit_actions(%i[create edit show destroy update index_users]) }

    context "and user is not a member of the group" do
      let(:group) { build :group, organisation_id: user.organisation_id + 1 }

      it "allows show, edit, update or destroy" do
        expect(policy).to permit_actions(%i[show edit update destroy index_users])
      end
    end

    it "scope resolves to all groups" do
      expect(GroupPolicy::Scope.new(user, Group).resolve).to eq(Group.all)
    end
  end

  context "when user is organisation_admin" do
    let(:user) { build :organisation_admin_user }

    it { is_expected.to permit_actions(%i[create edit show destroy update]) }

    context "and not a member of the group" do
      context "and in the same organisation as the group" do
        let(:group) { create :group, organisation_id: user.organisation_id }

        it "allows show, edit, update or destroy" do
          expect(policy).to permit_actions(%i[show edit update destroy])
        end
      end

      context "and not in the same organisation as the group" do
        let(:group) { build :group, organisation_id: user.organisation_id + 1 }

        it "forbids show, edit, update or destroy" do
          expect(policy).to forbid_actions(%i[show edit update destroy])
        end
      end
    end

    it "scope resolves to groups user organisation admin for" do
      expect(GroupPolicy::Scope.new(user, Group).resolve).to eq(Group.for_organisation(user.organisation))
    end
  end

  context "when user is editor" do
    it "allow creating new groups" do
      expect(policy).to permit_actions(%i[new create])
    end

    it "cannot view, list or modify group" do
      expect(policy).to forbid_actions(%i[edit show destroy update index_users])
    end

    context "and user belongs to group" do
      before { user.groups << group }

      it "allows view, list and modify group" do
        expect(policy).to permit_actions(%i[edit show destroy update index_users])
      end
    end

    it "scope resolves to only group user is a member of" do
      expect(GroupPolicy::Scope.new(user, Group).resolve).to eq(Group.for_user(user))
    end
  end
end
