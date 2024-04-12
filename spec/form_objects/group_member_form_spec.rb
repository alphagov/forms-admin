require "rails_helper"

describe GroupMemberForm do
  subject(:group_member_form) { described_class.new }

  let(:group) { create(:group) }
  let(:user) { create(:user, organisation: group.organisation) }

  describe "validations" do
    it "is valid with an email address" do
      group_member_form.member_email_address = user.email
      expect(group_member_form).to be_valid
    end

    it "is invalid without an email address" do
      group_member_form.member_email_address = ""
      error_message = I18n.t("activemodel.errors.models.group_member_form.attributes.member_email_address.blank")
      expect(group_member_form).not_to be_valid
      expect(group_member_form.errors[:member_email_address]).to include(error_message)
    end

    it "is invalid with a invalid email address " do
      group_member_form.member_email_address = "this isn't an email address"
      error_message = I18n.t("activemodel.errors.models.group_member_form.attributes.member_email_address.invalid_email")
      expect(group_member_form).not_to be_valid
      expect(group_member_form.errors[:member_email_address]).to include(error_message)
    end

    it "is invalid with a email address that is not a GOV.UK forms user" do
      group_member_form.member_email_address = "valid_but_not_user@email.gov.uk"
      error_message = I18n.t("activemodel.errors.models.group_member_form.attributes.member_email_address.not_forms_user")
      expect(group_member_form).not_to be_valid
      expect(group_member_form.errors[:member_email_address]).to include(error_message)
    end

    it "is valid with a email address that is a GOV.UK forms user" do
      user = create(:user)
      group_member_form.member_email_address = user.email
      expect(group_member_form).to be_valid
    end

    describe "#save" do
      context "when the new Membership has errors" do
        let(:group_member_form) { described_class.new }

        before do
          membership_errors = instance_double(ActiveModel::Errors)
          error = instance_double(ActiveModel::Error, type: :user_in_other_org)
          allow(membership_errors).to receive(:[]).with(:user_in_other_org).and_return(["User is already a member of another organization"])
          allow(membership_errors).to receive(:each).and_yield(error)

          new_membership = instance_double(Membership, invalid?: true, errors: membership_errors)

          memberships_association = instance_double(ActiveRecord::Associations::CollectionProxy)
          allow(memberships_association).to receive(:new).and_return(new_membership)

          group = instance_double(Group, memberships: memberships_association)

          group_member_form.group = group
          group_member_form.member_email_address = user.email
        end

        it "adds the appropriate error message to member_email_address" do
          error_message = I18n.t("activemodel.errors.models.group_member_form.attributes.member_email_address.user_in_other_org")
          expect(group_member_form.save).to be false
          expect(group_member_form.errors[:member_email_address]).to include(error_message)
        end
      end
    end
  end
end
