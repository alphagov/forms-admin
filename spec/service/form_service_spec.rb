require "rails_helper"

describe FormService do
  subject(:form_service) do
    described_class.new(form)
  end

  let(:id) { 1 }
  let(:form) { build(:form, id:) }

  describe "#path_for_state" do
    context "when form is live" do
      before do
        form.state = :live
      end

      it "returns live form path" do
        expect(form_service.path_for_state).to eq "/forms/#{id}/live"
      end
    end

    context "when form is archived" do
      before do
        form.state = :archived
      end

      it "returns archived form path" do
        expect(form_service.path_for_state).to eq "/forms/#{id}/archived"
      end
    end

    context "when form is draft" do
      before do
        form.state = :draft
      end

      it "returns draft form path" do
        expect(form_service.path_for_state).to eq "/forms/#{id}"
      end
    end
  end

  describe "#add_to_default_group" do
    context "when not a trial user" do
      it "creates a default group in the users organisation if it doesn't exist" do
        org = create :organisation
        user = build :editor_user, organisation: org

        expect {
          form_service.add_to_default_group!(user)
        }.to change(Group, :count).by(1)

        expect(Group.last).to have_attributes(organisation_id: org.id, name: "Test Org forms")
        expect(org.default_group_id).to eq Group.last.id
      end

      it "does not create a new default group if it already exists" do
        org = create :organisation, default_group: (create :group)
        user = build :editor_user, organisation: org

        expect {
          form_service.add_to_default_group!(user)
        }.to change(Group, :count).by(0)
      end

      it "adds the current user to the default group" do
        org = create :organisation
        user = build :editor_user, organisation: org

        form_service.add_to_default_group!(user)

        expect(org.default_group.users).to include(user)
      end

      context "when the organisation has not signed an MOU" do
        it "the default group will have trial status" do
          org = create :organisation
          user = build :editor_user, organisation: org

          form_service.add_to_default_group!(user)

          expect(org.default_group).to be_trial
        end
      end

      context "when the organisation has signed an MOU" do
        it "the default group will have active status" do
          org = create :organisation, :with_signed_mou
          user = build :editor_user, organisation: org

          form_service.add_to_default_group!(user)

          expect(org.default_group).to be_active
        end
      end

      it "creates a new GroupForm" do
        user = build :editor_user

        expect {
          form_service.add_to_default_group!(user)
        }.to change(GroupForm, :count).by(1)

        expect(GroupForm.last).to have_attributes(group_id: user.organisation.default_group.id, form_id: form.id)
      end
    end

    context "when user has a trial role" do
      it "creates a group if the user does not already have one" do
        user = create :user, name: "Batman"

        expect {
          form_service.add_to_default_group!(user)
        }.to change(Group, :count).by(1)

        expect(Group.last).to have_attributes(
          creator: user,
          name: "Batman’s trial group",
          organisation: user.organisation,
        )
        expect(Group.last).to be_trial
        expect(Group.last.users).to eq [user]
        expect(Group.last.users.group_admins).to eq [user]
      end

      it "does not create a group if the user already has one" do
        user = create :user, name: "Batman"
        group = create :group, creator: user, organisation: user.organisation, name: "Batman’s trial group", status: :trial

        expect {
          form_service.add_to_default_group!(user)
        }.not_to change(Group, :count)
        expect(group).to be_trial
        expect(group.users).to include user
        expect(Group.last.users.group_admins).to include user
      end

      it "adds their trial forms to the group" do
        user = create :user

        expect {
          form_service.add_to_default_group!(user)
        }.to change(GroupForm, :count).by(1)

        expect(GroupForm.last).to have_attributes(form_id: form.id)
      end

      it "raises an exception if it tries to add their trial forms to an active group" do
        user = create :user, name: "Batman"
        create :group, creator: user, organisation: user.organisation, name: "Batman’s trial group", status: :active

        expect {
          form_service.add_to_default_group!(user)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
