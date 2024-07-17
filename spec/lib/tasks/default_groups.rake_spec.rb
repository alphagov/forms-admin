require "rake"
require "rails_helper"

RSpec.describe "default_groups.rake" do
  before do
    Rake.application.rake_require "tasks/default_groups"
    Rake::Task.define_task(:environment)
  end

  describe "default_groups:create_for_trial_users" do
    subject(:task) do
      Rake::Task["default_groups:create_for_trial_users"]
        .tap(&:reenable)
    end

    let(:organisation) { create :organisation }
    let!(:editor_user) { create :user, organisation:, role: :editor }
    let!(:user) { create :user, organisation:, role: :trial }
    let(:forms_response) do
      build_list(:form, 3) do |form, i|
        form.id = i
      end
    end

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms?creator_id=#{user.id}", headers, forms_response.to_json, 200
      end
    end

    context "with the happy path" do
      before do
        task.invoke
      end

      it "creates a default group" do
        expect(Group.find_sole_by(creator: user)).not_to be_nil
      end

      it "adds user to group" do
        expect(user.groups).to include(Group.find_sole_by(creator: user))
      end

      it "adds user to group as group admin" do
        expect(Group.find_sole_by(creator: user).memberships.find_by(user:)).to be_group_admin
      end

      it "adds forms to group" do
        expect(Group.find_sole_by(creator: user).group_forms.count).to eq 3
      end

      it "the default group has trial status" do
        expect(Group.find_sole_by(creator: user)).to be_trial
      end

      it "does not create groups for editor users" do
        expect(Group.find_by(creator: editor_user)).to be_nil
      end
    end

    it "is idempotent" do
      task.invoke

      expect {
        task.invoke
      }.to not_change(Group, :count)
        .and not_change(Membership, :count)
        .and not_change(GroupForm, :count)
    end

    context "when the user has no forms" do
      let(:forms_response) { [] }

      it "does not create a default group" do
        task.invoke
        expect(Group.find_by(creator: user)).to be_nil
      end
    end
  end
end
