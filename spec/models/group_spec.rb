require "rails_helper"

RSpec.describe Group, type: :model do
  it "has a valid factory" do
    expect(build(:group)).to be_valid
  end

  describe "validations" do
    it "is invalid without a name" do
      group = build :group, name: nil
      expect(group).not_to be_valid
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
  end
end
