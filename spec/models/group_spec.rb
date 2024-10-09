require "rails_helper"

RSpec.describe Group, type: :model do
  it "has a valid factory" do
    expect(build(:group)).to be_valid
  end

  describe "validations" do
    it "is invalid without a name" do
      group = build :group, name: nil
      expect(group).not_to be_valid
      expect(group.errors.full_messages_for(:name)).to include("Name #{I18n.t('activerecord.errors.models.group.attributes.name.blank')}")
    end

    it "is invalid without an organisation" do
      group = build :group, organisation: nil
      expect(group).not_to be_valid
    end

    it "cannot be set to an invalid status" do
      group = build :group, status: :invalid
      expect(group).to be_invalid
    end

    it "is invalid without a status" do
      group = build :group, status: nil
      expect(group).not_to be_valid
    end

    it "is valid without a creator" do
      group = build :group, creator: nil
      expect(group).to be_valid
    end

    it "is valid without an upgrade requester" do
      group = build :group, upgrade_requester: nil
      expect(group).to be_valid
    end

    it "is invalid when a group already exists with the same name and organisation" do
      organisation = create :organisation
      create :group, organisation:, name: "Test group"
      group = build :group, organisation:, name: "Test group"

      expect(group).to be_invalid
      expect(group.errors[:name]).to eq([I18n.t("activerecord.errors.models.group.attributes.name.taken")])
    end

    it "is valid when two groups have the same name but different organisations" do
      organisation = create :organisation
      other_organisation = create :organisation, name: "other organisation", slug: "other-organisation"
      create :group, organisation:, name: "Test group"
      group = build :group, organisation: other_organisation, name: "Test group"

      expect(group).to be_valid
    end

    it "is valid when two groups have different names but the same organisation" do
      organisation = create :organisation
      create :group, organisation:, name: "Test group"
      group = build :group, organisation:, name: "Other group"

      expect(group).to be_valid
    end
  end

  describe "before_create" do
    it "sets the external_id" do
      group = create :group
      expect(group.external_id).to be_present
    end
  end

  describe "#to_param" do
    it "returns the external_id" do
      group = create :group
      expect(group.to_param).to eq group.external_id
    end
  end

  describe "unique external_id" do
    it "two models with the same external_id cannot be saved to the DB" do
      group1 = create :group
      group2 = create :group

      group2.external_id = group1.external_id
      expect { group2.save! }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe "associations" do
    it "destroys associated memberships" do
      group = create :group
      user = create :user
      added_by = create :user
      create(:membership, group:, user:, added_by:)

      expect { group.destroy }.to change(Membership, :count).by(-1)
    end

    it "does not destroy associated creator" do
      user = create :user
      group = create :group, creator: user

      expect { group.destroy }.not_to change(User, :count)
    end

    it "does not destroy associated upgrade requester" do
      user = create :user
      group = create :group, upgrade_requester: user

      expect { group.destroy }.not_to change(User, :count)
    end

    describe "#memberships" do
      describe "#ordered" do
        it "orders the membership records by name of the associated user" do
          group = create :group
          users = [
            create(:user, name: "Barbara User"),
            create(:user, name: "Alfred User"),
            create(:user, name: "Charlie User"),
          ]

          users.each do |user|
            Membership.create!(group:, user:, role: :editor, added_by: group.creator)
          end

          expect(group.memberships.ordered.map { _1.user.name }).to eq [
            "Alfred User",
            "Barbara User",
            "Charlie User",
          ]
        end
      end
    end

    describe "#users" do
      describe "#group_admins" do
        it "returns all users who are group admins for the group" do
          group = create :group
          group_admin_users = create_list :user, 3, organisation: group.organisation
          editor_users = create_list :user, 3, organisation: group.organisation

          group_admin_users.each do |user|
            Membership.create!(group:, user:, role: :group_admin, added_by: group.creator)
          end
          editor_users.each do |user|
            Membership.create!(group:, user:, role: :editor, added_by: group.creator)
          end

          expect(group.users.group_admins).to eq group_admin_users
        end
      end
    end
  end

  describe "associating forms with groups" do
    it "can have zero forms" do
      group = build :group

      expect(group.group_forms).to be_empty
    end

    it "can be associated with a form ID" do
      group = build(:group, id: 1)
      group.group_forms.build(form_id: 1)
      group.save!

      expect(described_class.find(1).group_forms).to eq [
        GroupForm.build(form_id: 1, group_id: 1),
      ]
    end

    it "can be associated with many form IDs" do
      group = build(:group, id: 1)
      group.group_forms.build(form_id: 2)
      group.group_forms.build(form_id: 3)
      group.group_forms.build(form_id: 4)
      group.save!

      expect(described_class.find(1).group_forms).to eq [
        GroupForm.build(form_id: 2, group_id: 1),
        GroupForm.build(form_id: 3, group_id: 1),
        GroupForm.build(form_id: 4, group_id: 1),
      ]
    end

    it "is associated with a form through the form ID" do
      form = build :form, id: 1

      ActiveResource::HttpMock.respond_to do |mock|
        request_headers = { "Accept" => "application/json", "X-API-Token" => Settings.forms_api.auth_key }
        mock.get "/api/v1/forms/1", request_headers, form.to_json, 200
      end

      group = build(:group, id: 1)
      group.group_forms.build(form_id: 1)
      group.save!

      expect(described_class.find(1).group_forms[0].form).to eq form
    end

    it "associates forms with groups through the form ID" do
      group = build(:group, id: 1)
      group.group_forms.build(form_id: 1)
      group.save!

      expect(GroupForm.find_by(form_id: 1).group).to eq group
    end

    it "raises an error if a form already belongs to a group" do
      group = build(:group, id: 1)
      group.group_forms.build(form_id: 1)
      group.save!

      other_group = build(:group, id: 2)
      other_group.group_forms.build(form_id: 1)

      expect { other_group.save! }.to raise_error ActiveRecord::RecordNotUnique
    end

    it "prevents deleting a group if it associated with one or more forms" do
      group = build(:group, id: 1)
      group.group_forms.build(form_id: 1)
      group.save!

      expect { group.destroy! }.to raise_error ActiveRecord::DeleteRestrictionError
    end
  end

  describe "scopes" do
    describe ".for_user" do
      it "returns groups that the user is a member of" do
        user = create :user
        group1 = create :group
        group2 = create :group
        create :group
        create :membership, user:, group: group1
        create :membership, user:, group: group2

        expect(described_class.for_user(user)).to eq [group1, group2]
      end

      it "returns an empty array if the user is not a member of any groups" do
        user = create :user
        create :group

        expect(described_class.for_user(user)).to eq []
      end

      it "does not return groups that the user is not a member of" do
        user = create :user
        group1 = create :group
        create :group
        create :group
        create :membership, user:, group: group1

        expect(described_class.for_user(user)).to eq [group1]
      end
    end

    describe ".for_organisation" do
      it "returns groups that match the given organisation" do
        org = create(:organisation, slug: "other org")

        group1 = create(:group)
        create(:group, organisation: org)

        expect(described_class.for_organisation(group1.organisation)).to eq [group1]
      end

      it "returns no groups for an unused organisation" do
        org = create(:organisation)

        expect(described_class.for_organisation(org)).to eq []
      end
    end
  end

  describe "status" do
    it "has a default status of trial" do
      group = described_class.build(name: "Test Group")
      expect(group.status).to eq("trial")
    end

    it "can be set to active" do
      group = build :group, status: :active
      expect(group).to be_valid
    end

    it "can be set to upgrade_requested" do
      group = build :group, status: :upgrade_requested
      expect(group).to be_valid
    end
  end

  describe "ordering" do
    it "orders groups by name" do
      user = create :user
      organisation = create :organisation
      group_c = create :group, organisation:, name: "C", creator: user
      group_b = create :group, organisation:, name: "b", creator: user
      group_a = create :group, organisation:, name: "a", creator: user

      expect(described_class.for_organisation(group_c.organisation)).to eq [group_a, group_b, group_c]
    end
  end
end
