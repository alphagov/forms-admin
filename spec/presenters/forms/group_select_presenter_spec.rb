require "rails_helper"

describe Forms::GroupSelectPresenter do
  let(:presenter) { described_class.new(form: form, group: group, groups: groups) }

  let(:form) { build :form, id: 1, name: "Test Form" }
  let(:group) { build :group, id: 1, name: "Test Group" }
  let(:groups) { build_list(:group, 5, organisation: group.organisation) }
  let(:group_select) { Forms::GroupSelect.new(group: group, form: form) }

  describe "#legend" do
    let(:groups) { [] }

    context "when there are no groups" do
      it "returns legend indicating no groups are available" do
        expect(presenter.legend).to eq("You have no other groups")
      end
    end

    context "when there are groups" do
      let(:groups) { build_list(:group, 5) }

      it "returns legend indicating groups are available" do
        expect(presenter.legend).to eq("What group do you want to move it to?")
      end
    end

    context "when the form is live" do
      let(:form) { build(:form, :live) }

      context "and there are no other active groups" do
        it "returns legend inidicating no other active groups" do
          expect(presenter.legend).to eq("You have no other active groups")
        end
      end

      context "and there are active groups" do
        let(:groups) { build_list(:group, 5, :active) }

        it "returns legend indicating groups are available" do
          expect(presenter.legend).to eq("What group do you want to move it to?")
        end
      end
    end
  end

  describe "#hint" do
    let(:groups) { [] }

    context "when there are no groups" do
      it "returns hint indicating a new group is needed" do
        expect(presenter.hint).to eq("You need to create a new group to move this form into.")
      end
    end

    context "and there are active groups" do
      let(:groups) { build_list(:group, 5, :active) }

      it "provides a hint indicating only active groups can be selected" do
        expect(presenter.hint).to be_nil
      end
    end

    context "when the form is live" do
      let(:form) { build(:form, :live) }

      context "and there are no other active groups" do
        it "returns hint indicating trial groups need upgrading" do
          expect(presenter.hint).to eq("You can only move a live form to another active group. You need to upgrade a trial group to move this form.")
        end
      end

      context "and there are active groups" do
        let(:groups) { build_list(:group, 5, :active) }

        it "provides no hint" do
          expect(presenter.hint).to eq("A live form cannot be moved to a trial group.")
        end
      end
    end
  end
end
