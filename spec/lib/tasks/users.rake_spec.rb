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
        }.not_to raise_error
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

  describe "users:delete_users_with_no_name_or_org" do
    subject(:task) do
      Rake::Task["users:delete_users_with_no_name_or_org"]
        .tap(&:reenable) # make sure task is invoked every time
    end

    let(:users) do
      [].concat(
        create_list(:user, 3, :old),
        create_list(:user, 3, :old, :with_no_name),
        create_list(:user, 3, :old, :with_no_org),
        create_list(:user, 3, :old, :with_no_name, :with_no_org),
      )
    end

    let(:forms) { [] }

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        forms_by_user_id = forms.group_by(&:creator_id)
        users.each do |user|
          mock.get "/api/v1/forms?creator_id=#{user.id}", headers, forms_by_user_id.fetch(user.id, []).to_json, 200
        end

        forms.each do |form|
          mock.delete "/api/v1/forms/#{form.id}", delete_headers, nil, 204
        end
      end

      allow(Rails.logger).to receive(:info)
    end

    it "deletes users with no name or organisation set" do
      expect {
        task.invoke
      }.to change(User, :count).to(3)
    end

    it "logs deleting each user" do
      task.invoke

      expect(Rails.logger).to have_received(:info).with(/delete_users_with_no_name_or_org: Deleted user \d+ \(.+@.+\)/).exactly(9)
    end

    it "logs the number of users deleted" do
      task.invoke

      expect(Rails.logger).to have_received(:info).with(/delete_users_with_no_name_or_org: Deleted 9 users/)
    end

    context "when the user has only just started using the service" do
      let!(:new_user) do
        users[8].update!(attributes_for(:user, :new, :with_no_org))
        users[8]
      end

      it "does not delete that user" do
        task.invoke

        expect(User.exists?(new_user.id)).to be true
      end

      it "deletes other users not in a group" do
        expect {
          task.invoke
        }.to change(User, :count).to(4)
      end

      it "logs that the user is being skipped" do
        task.invoke

        expect(Rails.logger).to have_received(:info).with(
          /delete_users_with_no_name_or_org: User could still have active session, skipping deleting user \d+/,
        )
      end

      it "counts the user as being skipped" do
        task.invoke

        expect(Rails.logger).to have_received(:info).with(
          /delete_users_with_no_name_or_org: Deleted 8 users, skipped deleting 1 users/,
        )
      end
    end

    context "when user is in one or more groups" do
      let(:user_in_group) { users.fifth }

      let(:forms) do
        build_list :form, 3, creator_id: user_in_group.id
      end

      before do
        group = create :group, creator: users.first
        create :membership, group:, user: user_in_group, added_by: users.first
      end

      it "does not delete that user" do
        task.invoke

        expect(User.exists?(user_in_group.id)).to be true
      end

      it "does not delete any of that user's forms" do
        task.invoke

        forms
          .select { |form| form.creator_id == user_in_group.id }
          .each do |form|
            expect(form).not_to have_been_deleted
          end
      end

      it "deletes other users not in a group" do
        expect {
          task.invoke
        }.to change(User, :count).to(4)
      end

      it "logs that the user is being skipped" do
        task.invoke

        expect(Rails.logger).to have_received(:info).with(
          /delete_users_with_no_name_or_org: Found user in groups \[\d+\], skipping deleting user \d+/,
        )
      end

      it "counts the user as being skipped" do
        task.invoke

        expect(Rails.logger).to have_received(:info).with(
          /delete_users_with_no_name_or_org: Deleted 8 users, skipped deleting 1 users/,
        )
      end
    end

    context "when user has created one or more forms" do
      let(:forms) do
        [
          build(:form, id: 99, creator_id: users.first.id),
          build(:form, id: 1, creator_id: users.last.id),
          build(:form, id: 2, creator_id: users.second_to_last.id),
          build(:form, id: 3, creator_id: users.second_to_last.id),
        ]
      end

      it "deletes the forms" do
        task.invoke

        expect(ActiveResource::HttpMock
          .requests.count { |request| request.method == :delete })
          .to eq 3
      end

      it "logs deleting each form" do
        task.invoke

        expect(Rails.logger).to have_received(:info).with(/delete_users_with_no_name_or_org: Deleted form 1/)
        expect(Rails.logger).to have_received(:info).with(/delete_users_with_no_name_or_org: Deleted form 2/)
        expect(Rails.logger).to have_received(:info).with(/delete_users_with_no_name_or_org: Deleted form 3/)
      end

      context "and one or more of the forms have been made live" do
        let(:user_with_live_form) { users.second_to_last }
        let(:forms) do
          [
            build(:form, id: 99, creator_id: users.first.id),
            build(:form, id: 1, creator_id: users.last.id),
            build(:form, id: 2, creator_id: user_with_live_form.id),
            build(:form, :live, id: 3, creator_id: user_with_live_form.id),
          ]
        end

        it "does not delete that user" do
          task.invoke

          expect(User.exists?(user_with_live_form.id)).to be true
        end

        it "does not delete any of that user's forms" do
          task.invoke

          forms
            .select { |form| form.creator_id == user_with_live_form.id }
            .each do |form|
              expect(form).not_to have_been_deleted
            end
        end

        it "deletes other users without live forms" do
          expect {
            task.invoke
          }.to change(User, :count).to(4)
        end

        it "logs that the user is being skipped" do
          task.invoke

          expect(Rails.logger).to have_received(:info).with(
            /delete_users_with_no_name_or_org: Found live forms \[3\] created by user, skipping deleting user \d+/,
          )
        end

        it "counts the user as being skipped" do
          task.invoke

          expect(Rails.logger).to have_received(:info).with(
            /delete_users_with_no_name_or_org: Deleted 8 users, skipped deleting 1 users/,
          )
        end
      end

      context "and one or more of the forms are in a group" do
        let(:user_with_form_in_group) { users.last }

        let(:form_in_group) { forms.last }

        let(:forms) do
          [
            build(:form, id: 99, creator_id: users.first.id),
            build(:form, id: 1, creator_id: user_with_form_in_group.id),
            build(:form, id: 2, creator_id: users.second_to_last.id),
            build(:form, id: 3, creator_id: users.second_to_last.id),
            build(:form, id: 4, creator_id: user_with_form_in_group.id),
          ]
        end

        before do
          GroupForm.create!(
            form_id: form_in_group.id,
            group: create(:group, creator: users.first),
          )
        end

        it "does not delete that user" do
          task.invoke

          expect(User.exists?(user_with_form_in_group.id)).to be true
        end

        it "does not delete any of that user's forms" do
          task.invoke

          forms
            .select { |form| form.creator_id == user_with_form_in_group.id }
            .each do |form|
              expect(form).not_to have_been_deleted
            end
        end

        it "deletes other users without forms in groups" do
          expect {
            task.invoke
          }.to change(User, :count).to(4)
        end

        it "logs that the user is being skipped" do
          task.invoke

          expect(Rails.logger).to have_received(:info).with(
            /delete_users_with_no_name_or_org: Found forms \[4\] created by user in groups, skipping deleting user \d+/,
          )
        end

        it "counts the user as being skipped" do
          task.invoke

          expect(Rails.logger).to have_received(:info).with(
            /delete_users_with_no_name_or_org: Deleted 8 users, skipped deleting 1 users/,
          )
        end
      end
    end

    describe ":dry_run" do
      subject(:dry_run_task) do
        Rake::Task["users:delete_users_with_no_name_or_org:dry_run"]
          .tap(&:reenable) # make sure task is invoked every time
      end

      let(:user_in_group) { users.fifth }
      let(:user_with_live_form) { users.second_to_last }
      let(:user_with_form_in_group) { users.last }

      let(:group_with_user) { create :group, creator: users.first }
      let(:form_in_group) { forms.last }

      let(:forms) do
        [
          build(:form, id: 99, creator_id: users.first.id),
          build(:form, id: 1, creator_id: user_with_form_in_group.id),
          build(:form, id: 2, creator_id: user_with_live_form.id),
          build(:form, :live, id: 3, creator_id: user_with_live_form.id),
          build(:form, id: 5, creator_id: users[5].id),
          build(:form, id: 7, creator_id: users[7].id),
          build(:form, id: 4, creator_id: user_with_form_in_group.id),
        ]
      end

      before do
        create :membership, group: group_with_user, user: user_in_group, added_by: users.first

        GroupForm.create!(
          form_id: form_in_group.id,
          group: create(:group, creator: users.first),
        )
      end

      it "logs the changes that would be made" do
        dry_run_task.invoke

        [
          "users:delete_users_with_no_name_or_org:dry_run: Found 9 users without a name or organisation set",

          "users:delete_users_with_no_name_or_org:dry_run: Found user #{users[3].id} (#{users[3].email}) without a name or organisation set",
          "users:delete_users_with_no_name_or_org:dry_run: Deleted user #{users[3].id} (#{users[3].email})",

          "users:delete_users_with_no_name_or_org:dry_run: Found user #{user_in_group.id} (#{user_in_group.email}) without a name or organisation set",
          "users:delete_users_with_no_name_or_org:dry_run: Found user in groups [#{group_with_user.id}], skipping deleting user #{user_in_group.id} (#{user_in_group.email})",

          "users:delete_users_with_no_name_or_org:dry_run: Found user #{users[5].id} (#{users[5].email}) without a name or organisation set",
          /users:delete_users_with_no_name_or_org:dry_run: Deleted form 5 \(".+"\) created by user #{users[5].id} \(#{users[5].email}\)/,
          "users:delete_users_with_no_name_or_org:dry_run: Deleted user #{users[5].id} (#{users[5].email})",

          "users:delete_users_with_no_name_or_org:dry_run: Found user #{users[6].id} (#{users[6].email}) without a name or organisation set",
          "users:delete_users_with_no_name_or_org:dry_run: Deleted user #{users[6].id} (#{users[6].email})",

          "users:delete_users_with_no_name_or_org:dry_run: Found user #{users[7].id} (#{users[7].email}) without a name or organisation set",
          /users:delete_users_with_no_name_or_org:dry_run: Deleted form 7 \(".+"\) created by user #{users[7].id} \(#{users[7].email}\)/,
          "users:delete_users_with_no_name_or_org:dry_run: Deleted user #{users[7].id} (#{users[7].email})",

          "users:delete_users_with_no_name_or_org:dry_run: Found user #{users[8].id} (#{users[8].email}) without a name or organisation set",
          "users:delete_users_with_no_name_or_org:dry_run: Deleted user #{users[8].id} (#{users[8].email})",

          "users:delete_users_with_no_name_or_org:dry_run: Found user #{users[9].id} (#{users[9].email}) without a name or organisation set",
          "users:delete_users_with_no_name_or_org:dry_run: Deleted user #{users[9].id} (#{users[9].email})",

          "users:delete_users_with_no_name_or_org:dry_run: Found user #{user_with_live_form.id} (#{user_with_live_form.email}) without a name or organisation set",
          "users:delete_users_with_no_name_or_org:dry_run: Found live forms [3] created by user, skipping deleting user #{user_with_live_form.id} (#{user_with_live_form.email})",

          "users:delete_users_with_no_name_or_org:dry_run: Found user #{user_with_form_in_group.id} (#{users[11].email}) without a name or organisation set",
          "users:delete_users_with_no_name_or_org:dry_run: Found forms [4] created by user in groups, skipping deleting user #{user_with_form_in_group.id} (#{user_with_form_in_group.email})",

          "users:delete_users_with_no_name_or_org:dry_run: Deleted 6 users, skipped deleting 3 users",
          "users:delete_users_with_no_name_or_org:dry_run: Finished dry run, no changes persisted",
        ].each do |line|
          expect(Rails.logger).to have_received(:info).with(a_string_matching(line))
        end
      end

      it "does not delete any users" do
        expect {
          dry_run_task.invoke
        }.not_to change(User, :count)
      end

      it "does not delete any forms" do
        dry_run_task.invoke

        expect(ActiveResource::HttpMock
          .requests.select { |request| request.method == :delete })
          .to be_empty
      end
    end
  end
end
