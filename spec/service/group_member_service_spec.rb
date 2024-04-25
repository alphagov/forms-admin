require "rails_helper"

describe GroupMemberService do
  subject(:service) { described_class.new(group:, current_user:) }

  let(:group) { create(:group) }
  let(:current_user) { create(:user) }
  let(:membership1) { create(:membership, group:, user: create(:user), role: "editor") }
  let(:membership2) { create(:membership, group:, user: create(:user), role: "group_admin") }

  describe ".call" do
    it "creates a new instance of GroupMemberService" do
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
      rows = service.rows

      expect(rows).to be_an(Array)
      expect(rows.first).to be_an_instance_of(GroupMemberService::Row)
    end

    it "includes the correct data in each row" do
      rows = service.rows

      expect(rows.first.name).to eq(membership1.user.name)
      expect(rows.first.email).to eq(membership1.user.email)
      expect(rows.first.role).to eq(membership1.role)
      expect(rows.first.membership).to eq(membership1)
    end

    context "when the user is a group admin" do
      before do
        allow(current_user).to receive(:is_group_admin?).and_return(true)
      end

      it "includes the correct actions in each row" do
        rows = service.rows

        expect(rows.first.actions).to eq([:delete])
        expect(rows.last.actions).to eq([])
      end
    end

    context "when the user is a super admin" do
      let(:current_user) { create(:user, :super_admin) }

      it "includes the correct actions in each row" do
        rows = service.rows

        expect(rows.first.actions).to eq(%i[delete make_group_admin])
        expect(rows.last.actions).to eq(%i[delete make_editor])
      end
    end
  end
end
