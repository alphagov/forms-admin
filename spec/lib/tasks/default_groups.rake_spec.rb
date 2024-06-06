require "rake"
require "rails_helper"

RSpec.describe "default_groups.rake" do
  before do
    Rake.application.rake_require "tasks/default_groups"
    Rake::Task.define_task(:environment)
  end

  describe "default_groups:create" do
    subject(:task) do
      Rake::Task["default_groups:create"]
        .tap(&:reenable)
    end

    let(:organisation) { create :organisation }
    let!(:user) { create :editor_user, organisation: }
    let!(:trial_user) { create :user, organisation: }
    let(:forms_response) do
      build_list(:form, 3) do |form, i|
        form.id = i
      end
    end

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms?organisation_id=#{organisation.id}", headers, forms_response.to_json, 200
      end
    end

    context "with the happy path" do
      before do
        task.invoke
      end

      it "creates a default group" do
        expect(organisation.reload.default_group).not_to be_nil
      end

      it "adds user to group" do
        expect(user.groups).to include(organisation.reload.default_group)
      end

      it "adds user to group as editor" do
        expect(organisation.reload.default_group.memberships.find_by(user:)).to be_editor
      end

      it "does not add trial user to group" do
        expect(trial_user.groups).not_to include(organisation.reload.default_group)
      end

      it "adds forms to group" do
        expect(organisation.reload.default_group.group_forms.count).to eq 3
      end

      it "the default group has trial status" do
        expect(organisation.reload.default_group).to be_trial
      end
    end

    it "is idempotent" do
      task.invoke

      expect {
        task.invoke
      }.to change(Group, :count).by(0)
        .and change(Membership, :count).by(0)
        .and change(GroupForm, :count).by(0)
    end

    context "when the organisation has no users" do
      let(:user) { nil }

      it "does not create a default group" do
        task.invoke
        expect(organisation.reload.default_group).to be_nil
      end
    end

    context "when the organisation has a signed MOU" do
      let(:organisation) { create :organisation, :with_signed_mou }

      it "the default group has active status" do
        task.invoke
        expect(organisation.reload.default_group).to be_active
      end
    end

    context "when a default group already exists" do
      let(:group) { create :group, organisation: }

      it "does not create a new default group" do
        organisation.default_group = group
        organisation.save!
        task.invoke
        expect(organisation.reload.default_group).to eq group
      end
    end

    context "when the form is already in a group" do
      let(:group) { create(:group, organisation:) }

      it "does not add it to the default group" do
        group.group_forms.build(form_id: forms_response.first.id)
        group.save!
        task.invoke
        expect(organisation.reload.default_group.group_forms.map(&:form_id)).not_to include forms_response.first.id
      end
    end
  end
end
