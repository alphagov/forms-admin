require "rake"

require "rails_helper"

RSpec.describe "users.rake" do
  before do
    Rake.application.rake_require "tasks/users"
    Rake::Task.define_task(:environment)
  end

  describe "users:update_user_roles_to_standard" do
    subject(:task) do
      Rake::Task["users:update_user_roles_to_standard"]
        .tap(&:reenable) # make sure task is invoked every time
    end

    let!(:super_admin_user) { create(:user, :super_admin) }
    let!(:org_admin_user) { create(:organisation_admin_user) }

    before do
      task.invoke
    end

    it "does not update the role for a super_admin user" do
      expect(super_admin_user.reload.role).to eq("super_admin")
    end

    it "does not update the role for a organisation_admin user" do
      expect(org_admin_user.reload.role).to eq("organisation_admin")
    end
  end

  describe "users:delete_user_dry_run" do
    subject(:task) do
      Rake::Task["users:delete_user_dry_run"]
        .tap(&:reenable) # make sure task is invoked every time
    end

    let!(:user_to_delete) { create(:user) }

    context "when a user ID is provided" do
      it "does not delete the user" do
        expect {
          task.invoke(user_to_delete.id)

          user_to_delete.reload
        }.not_to raise_error(ActiveRecord::RecordNotFound)
      end

      it "logs the deletion and the rollback" do
        expect(Rails.logger).to receive(:info).with("Deleted user: #{user_to_delete.id}")
        expect(Rails.logger).to receive(:info).with("users:delete_user_dry_run: rollback deletion of user #{user_to_delete.id}")
        task.invoke(user_to_delete.id)
      end
    end

    context "when a user ID is not provided" do
      it "aborts with a usage message" do
        expect {
          task.invoke
        }.to raise_error(SystemExit)
        .and output("usage: rake delete_user_dry_run[<user_id>]\n").to_stderr
      end
    end
  end

  describe "users:delete_user" do
    subject(:task) do
      Rake::Task["users:delete_user"]
        .tap(&:reenable) # make sure task is invoked every time
    end

    let!(:user_to_delete) { create(:user) }

    context "when a user ID is provided" do
      it "deletes the user" do
        expect {
          task.invoke(user_to_delete.id)

          user_to_delete.reload
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "logs the deletion" do
        expect(Rails.logger).to receive(:info).with("Deleted user: #{user_to_delete.id}")
        task.invoke(user_to_delete.id)
      end
    end

    context "when a user ID is not provided" do
      it "aborts with a usage message" do
        expect {
          task.invoke
        }.to raise_error(SystemExit)
        .and output("usage: rake delete_user[<user_id>]\n").to_stderr
      end
    end
  end
end
