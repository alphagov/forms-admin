require "rake"
require "rails_helper"

RSpec.describe "groups.rake" do
  before do
    Rake.application.rake_require "tasks/groups"
    Rake::Task.define_task(:environment)
  end

  describe "groups:change_organisation" do
    subject(:task) { Rake::Task["groups:change_organisation"].tap(&:reenable) }

    let(:start_org) { create(:organisation, slug: "start-org") }
    let(:target_org) { create(:organisation, slug: "target-org") }

    let(:groups) do
      create_list(:group, 3, organisation: start_org)
    end

    let(:single_group) { groups.first }

    context "with valid arguments" do
      context "with a single group" do
        it "changes the group organisation to target organisation" do
          expect {
            task.invoke(single_group.external_id, target_org.id)
          }.to change { single_group.reload.organisation }.from(start_org).to(target_org)
        end
      end

      context "with multiple groups" do
        it "changes the organisations of all specified groups to the target organisation" do
          group_ids = groups.map(&:external_id)

          expect {
            task.invoke(*group_ids, target_org.id)
          }.to change { groups.map { |g| g.reload.organisation } }.to([target_org] * groups.size)
        end
      end
    end

    context "with invalid arguments" do
      it "aborts when group_ids are empty" do
        expect {
          task.invoke
        }.to raise_error(SystemExit).and output(/usage: rake groups:change_organisation/).to_stderr
      end

      it "aborts when org_id is missing" do
        expect {
          task.invoke(single_group.external_id)
        }.to raise_error(SystemExit).and output(/usage: rake groups:change_organisation/).to_stderr
      end

      it "aborts when the organisation is not found" do
        non_existent_org_id = 999_999

        expect {
          task.invoke(single_group.external_id, non_existent_org_id)
        }.to raise_error(SystemExit).and output(/Organisation with ID #{non_existent_org_id} not found!/).to_stderr
      end

      it "aborts when any groups are not found" do
        non_existent_group_ids = [999_998, 999_999]

        expect {
          task.invoke(*non_existent_group_ids, target_org.id)
        }.to raise_error(SystemExit).and output(/Groups with external ids #{non_existent_group_ids.join(', ')} not found!/).to_stderr
      end

      it "aborts when some groups are not found" do
        existent_group_id = single_group.external_id
        non_existent_group_id = 999_999

        expect {
          task.invoke(existent_group_id, non_existent_group_id, target_org.id)
        }.to raise_error(SystemExit).and output(/Groups with external ids #{non_existent_group_id} not found!/).to_stderr
      end
    end
  end

  describe "groups:change_organisation_dry_run" do
    subject(:task) { Rake::Task["groups:change_organisation_dry_run"].tap(&:reenable) }

    let(:start_org) { create(:organisation, slug: "start-org") }
    let(:target_org) { create(:organisation, slug: "target-org") }

    let(:groups) do
      create_list(:group, 3, organisation: start_org)
    end

    let(:single_group) { groups.first }

    context "with valid arguments" do
      context "with a single group" do
        it "does not persist the organisation change" do
          expect {
            task.invoke(single_group.external_id, target_org.id)
          }.not_to(change { single_group.reload.organisation })
        end
      end

      context "with multiple groups" do
        it "does not persist the organisation changes for any specified groups" do
          group_ids = groups.map(&:external_id)

          expect {
            task.invoke(*group_ids, target_org.id)
          }.not_to(change { groups.map { |g| g.reload.organisation } })
        end
      end
    end

    context "with invalid arguments" do
      it "aborts when args are empty" do
        expect {
          task.invoke
        }.to raise_error(SystemExit).and output(/usage: rake groups:change_organisation_dry_run/).to_stderr
      end
    end
  end
end
