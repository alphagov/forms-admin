require "rails_helper"

RSpec.describe DefaultGroupService do
  subject(:default_group_service) do
    described_class.new
  end

  describe "#create_trial_user_default_group!" do
    let(:user) { create :user, name: "Batman" }
    let(:form) { build :form, id: 1 }
    let(:forms_response) do
      [form]
    end

    before do
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/api/v1/forms?creator_id=#{user.id}", headers, forms_response.to_json, 200
      end
    end

    context "when the user has the trial role" do
      context "when the user does not already have a trial group" do
        it "creates a group" do
          expect {
            default_group_service.create_trial_user_default_group!(user)
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

        it "adds their trial forms to the group" do
          expect {
            default_group_service.create_trial_user_default_group!(user)
          }.to change(GroupForm, :count).by(1)

          expect(GroupForm.last).to have_attributes(form_id: form.id)
        end

        context "when the user does not have a name" do
          let(:user) { create :user, name: "" }

          it "returns nil" do
            expect(
              default_group_service.create_trial_user_default_group!(user),
            ).to be_nil
          end
        end

        context "when the user does not have an organisation" do
          let(:user) { create :user, :with_no_org }

          it "returns nil" do
            expect(
              default_group_service.create_trial_user_default_group!(user),
            ).to be_nil
          end
        end

        context "when the user doesn't have any forms" do
          let(:forms_response) do
            []
          end

          it "returns nil" do
            expect(
              default_group_service.create_trial_user_default_group!(user),
            ).to be_nil
          end
        end
      end

      context "when the user already has a group" do
        context "and the group status is 'trial'" do
          it "does not create a group " do
            group = create :group, creator: user, organisation: user.organisation, name: "Batman’s trial group", status: :trial

            expect {
              default_group_service.create_trial_user_default_group!(user)
            }.not_to change(Group, :count)
            expect(group).to be_trial
            expect(group.users).to include user
            expect(Group.last.users.group_admins).to include user
          end
        end

        context "and the group status is 'active'" do
          it "raises an exception" do
            create :group, creator: user, organisation: user.organisation, name: "Batman’s trial group", status: :active

            expect {
              default_group_service.create_trial_user_default_group!(user)
            }.to raise_error(ActiveRecord::RecordInvalid)
          end
        end
      end

      context "when the user's forms are already in a group" do
        it "returns nil" do
          group = create :group, creator: user, organisation: user.organisation
          GroupForm.create!(form_id: form.id, group_id: group.id)

          expect(
            default_group_service.create_trial_user_default_group!(user),
          ).to be_nil
        end
      end
    end

    context "when the user does not have the trial role" do
      let(:user) { create :user, name: "Batman", role: :editor }

      it "returns nil" do
        expect(
          default_group_service.create_trial_user_default_group!(user),
        ).to be_nil
      end
    end
  end
end
