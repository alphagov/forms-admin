require "rails_helper"

describe UserPolicy do
  subject(:policy) { described_class.new(user, records) }

  let(:user) { build :super_admin_user }
  let!(:records) { create_list :user, 5 }

  context "with super admin" do
    it { is_expected.to permit_actions(%i[can_manage_user]) }
  end

  context "with editor" do
    let(:user) { build :editor_user }

    it { is_expected.to forbid_actions(%i[can_manage_user]) }
  end

  describe UserPolicy::Scope do
    subject(:policy_scope) { described_class.new(user, User) }

    context "with super admin" do
      it "returns a list of users" do
        expect(policy_scope.resolve).to eq(records)
      end
    end

    context "with editor" do
      let(:user) { build :editor_user }

      it "returns nil" do
        expect(policy_scope.resolve).to be_nil
      end
    end
  end
end
