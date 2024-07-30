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
    let!(:editor_user) { create(:user, :editor) }
    let!(:trial_user) { create(:user, :trial) }

    before do
      task.invoke
    end

    it "updates the role for a trial user" do
      expect(trial_user.reload.role).to eq("standard")
    end

    it "updates the role for an editor user" do
      expect(editor_user.reload.role).to eq("standard")
    end

    it "does not update the role for a super_admin user" do
      expect(super_admin_user.reload.role).to eq("super_admin")
    end

    it "does not update the role for a organisation_admin user" do
      expect(org_admin_user.reload.role).to eq("organisation_admin")
    end
  end
end
