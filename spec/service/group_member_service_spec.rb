require "rails_helper"

describe GroupMemberService do
  let(:group) { create(:group) }
  let(:current_user) { create(:user) }
  let(:membership1) { create(:membership, group:, user: create(:user), role: "editor") }
  let(:membership2) { create(:membership, group:, user: create(:user), role: "group_admin") }

  describe ".call" do
    it "creates a new instance of GroupMemberService" do
      service = described_class.call(group:, current_user:)
      expect(service).to be_an_instance_of(described_class)
    end
  end

  describe "#show_actions?" do
    context "when current user is a super admin" do
      let(:current_user) { create(:user, role: "super_admin") }

      it "returns true" do
        service = described_class.new(group:, current_user:)
        expect(service.show_actions?).to be true
      end
    end

    context "when current user is an organisation admin" do
      before do
        allow(current_user).to receive(:is_organisations_admin?).and_return(true)
      end

      it "returns true" do
        service = described_class.new(group:, current_user:)
        expect(service.show_actions?).to be true
      end
    end

    context "when current user is a group admin" do
      before do
        allow(current_user).to receive(:is_group_admin?).and_return(true)
      end

      it "returns true" do
        service = described_class.new(group:, current_user:)
        expect(service.show_actions?).to be true
      end
    end

    context "when current user is a regular user" do
      it "returns false" do
        service = described_class.new(group:, current_user:)
        expect(service).not_to be_show_actions
      end
    end
  end

  describe "#rows" do
    before do
      membership1
      membership2
    end

    it "returns an array of Row structs" do
      service = described_class.new(group:, current_user:)
      rows = service.rows

      expect(rows).to be_an(Array)
      expect(rows.first).to be_an_instance_of(GroupMemberService::Row)
    end

    it "includes the correct data in each row" do
      service = described_class.new(group:, current_user:)
      rows = service.rows

      expect(rows.first.name).to eq(membership1.user.name)
      expect(rows.first.email).to eq(membership1.user.email)
      expect(rows.first.role).to eq(membership1.role)
      expect(rows.first.membership).to eq(membership1)
    end
  end

  describe "#actions" do
    context "when current user can destroy the membership" do
      before do
        allow(Pundit).to receive(:policy).and_return(instance_double(MembershipPolicy, destroy?: true))
      end

      it "includes the delete action" do
        service = described_class.new(group:, current_user:)
        actions = service.send(:actions, membership1)

        expect(actions).to include(:delete)
      end
    end

    context "when current user cannot destroy the membership" do
      before do
        allow(Pundit).to receive(:policy).and_return(instance_double(MembershipPolicy, destroy?: false))
      end

      it "does not include the delete action" do
        service = described_class.new(group:, current_user:)
        actions = service.send(:actions, membership1)

        expect(actions).not_to include(:delete)
      end
    end
  end
end
