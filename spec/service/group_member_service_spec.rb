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
    context "when any row has actions" do
      let(:row_with_actions) { instance_double(GroupMemberService::Row, actions: [:delete]) }
      let(:rows) { [row_with_actions] }

      it "returns true" do
        service = described_class.new(group:, current_user:)
        allow(service).to receive(:rows).and_return(rows)
        expect(service.show_actions?).to be(true)
      end
    end

    context "when no rows have actions" do
      let(:row_without_actions) { instance_double(GroupMemberService::Row, actions: []) }
      let(:rows) { [row_without_actions] }

      it "returns false" do
        service = described_class.new(group:, current_user:)
        allow(service).to receive(:rows).and_return(rows)
        expect(service.show_actions?).to be(false)
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
