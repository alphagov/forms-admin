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

  describe "groups:move_all_groups_between_organisations" do
    subject(:task) do
      Rake::Task["groups:move_all_groups_between_organisations"]
        .tap(&:reenable)
    end

    let(:source_organisation) { create :organisation, slug: "source-organisation", id: 1 }
    let(:target_organisation) { create :organisation, slug: "new-org", id: 2 }
    let(:group) { create :group, organisation: source_organisation }

    context "with valid arguments" do
      let(:valid_args) { [source_organisation.id, target_organisation.id] }

      it "moves the group to the new org" do
        expect {
          task.invoke(*valid_args)
        }.to change { group.reload.organisation }.from(source_organisation).to(target_organisation)
      end
    end

    context "with invalid arguments" do
      shared_examples_for "usage error" do
        it "aborts with a usage message" do
          expect {
            task.invoke(*invalid_args)
          }.to raise_error(SystemExit)
           .and output("usage: rake groups:move_all_groups_between_organisations[<source_organisation_id>, <target_organisation_id>]\n").to_stderr
        end
      end

      context "with no arguments" do
        it_behaves_like "usage error" do
          let(:invalid_args) { [] }
        end
      end

      context "with only one argument" do
        it_behaves_like "usage error" do
          let(:invalid_args) { [source_organisation.id] }
        end
      end

      context "with invalid source_organisation id" do
        let(:invalid_args) { ["some_id_that_does_not_exist", target_organisation.id] }

        it "raises an error" do
          expect {
            task.invoke(*invalid_args)
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context "with invalid target_organisation id" do
      let(:invalid_args) { [source_organisation.id, "some_id_that_does_not_exist"] }

      it "raises an error" do
        expect {
          task.invoke(*invalid_args)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "groups:move_all_groups_between_organisations_dry_run" do
    subject(:task) do
      Rake::Task["groups:move_all_groups_between_organisations_dry_run"]
        .tap(&:reenable)
    end

    let(:source_organisation) { create :organisation, slug: "source-organisation", id: 1 }
    let(:target_organisation) { create :organisation, slug: "new-org", id: 2 }
    let(:group) { create :group, organisation: source_organisation }

    context "with valid arguments" do
      let(:valid_args) { [source_organisation.id, target_organisation.id] }

      it "does not persist the organisation change for the groups" do
        expect {
          task.invoke(*valid_args)
        }.not_to(change { group.reload.organisation })
      end
    end

    context "with invalid arguments" do
      shared_examples_for "usage error" do
        it "aborts with a usage message" do
          expect {
            task.invoke(*invalid_args)
          }.to raise_error(SystemExit)
           .and output("usage: rake groups:move_all_groups_between_organisations_dry_run[<source_organisation_id>, <target_organisation_id>]\n").to_stderr
        end
      end

      context "with no arguments" do
        it_behaves_like "usage error" do
          let(:invalid_args) { [] }
        end
      end

      context "with only one argument" do
        it_behaves_like "usage error" do
          let(:invalid_args) { [source_organisation.id] }
        end
      end

      context "with invalid source_organisation id" do
        let(:invalid_args) { ["some_id_that_does_not_exist", target_organisation.id] }

        it "raises an error" do
          expect {
            task.invoke(*invalid_args)
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context "with invalid target_organisation id" do
      let(:invalid_args) { [source_organisation.id, "some_id_that_does_not_exist"] }

      it "raises an error" do
        expect {
          task.invoke(*invalid_args)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "groups:remove_group" do
    subject(:task) { Rake::Task["groups:remove_group"].tap(&:reenable) }

    it "with correct arguments removes the group" do
      group = create(:group)

      expect {
        task.invoke(group.external_id)
      }.to change(Group, :count).by(-1)
    end

    it "with no arguments raises an error" do
      expect {
        task.invoke
      }.to raise_error(SystemExit)
      .and output(/usage/).to_stderr
    end

    it "with invalid group id raises an error" do
      invalid_args = %w[some_id_that_does_not_exist]
      expect {
        task.invoke(*invalid_args)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "with group that has forms raises an error" do
      group = create(:group)
      group.group_forms.create!(form_id: 1)
      group.save!
      expect {
        task.invoke(group.external_id)
      }.to raise_error(SystemExit)
    end
  end

  describe "groups:remove_group_dry_run" do
    subject(:task) { Rake::Task["groups:remove_group_dry_run"].tap(&:reenable) }

    it "with correct arguments does not remove the group" do
      group = create(:group)

      expect {
        task.invoke(group.external_id)
      }.not_to change(Group, :count)
    end
  end
end
