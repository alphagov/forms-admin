require "rails_helper"

RSpec.describe GroupFormsService do
  subject(:group_forms_service) do
    described_class.new(group:, form:, current_user:, old_group:)
  end

  describe "#move_form" do
    let(:org) { create :organisation, :with_signed_mou }
    let(:current_user) { create(:organisation_admin_user, organisation: org) }
    let(:other_user) { create(:organisation_admin_user, organisation: org) }
    let(:old_group) { create :group, id: 1, organisation: org }
    let(:group) { create(:group, id: 2, organisation: org) }
    let(:form) { create :form, id: 1 }
    let(:delivery) { double }

    before do
      GroupForm.create!(group: old_group, form_id: form.id)
    end

    it "moves the form to the new group" do
      group_forms_service.move_form_to(group)

      group_form = GroupForm.find_by(group: group, form_id: form.id)
      expect(group_form.group_id).to eq(group.id)
    end

    describe "sending emails" do
      before do
        allow(GroupFormsMoveMailer).to receive_messages(form_moved_email_org_admin: delivery, form_moved_email_group_admin: delivery)
        allow(delivery).to receive(:deliver_now).with(any_args)
      end

      context "when there are other org admins" do
        let(:org_admins) { create_list(:organisation_admin_user, 2, organisation: org) }

        before do
          org_admins.each do |admin|
            Membership.create!(group: old_group, user: admin, role: :group_admin, added_by_id: current_user.id)
          end
        end

        it "sends emails to other org admins" do
          group_forms_service.move_form_to(group)

          expect(delivery).to have_received(:deliver_now).with(any_args).exactly(2).times

          org_admins.each do |org_admin|
            expect(GroupFormsMoveMailer).to have_received(:form_moved_email_org_admin).with(
              to_email: org_admin.email,
              form_name: form.name,
              old_group_name: old_group.name,
              new_group_name: group.name,
              org_admin_email: current_user.email,
              org_admin_name: current_user.name,
            )
          end
        end
      end

      context "when there are other group admins" do
        let(:group_admins) { create_list(:user, 2, organisation: org) }

        before do
          group_admins.each do |admin|
            Membership.create!(group: old_group, user: admin, role: :group_admin, added_by_id: current_user.id)
          end
        end

        it "sends emails to group admins and editors" do
          group_forms_service.move_form_to(group)

          expect(delivery).to have_received(:deliver_now).with(any_args).exactly(2).times

          group_admins.each do |user|
            expect(GroupFormsMoveMailer).to have_received(:form_moved_email_group_admin).with(
              to_email: user.email,
              form_name: form.name,
              old_group_name: old_group.name,
              new_group_name: group.name,
              org_admin_email: current_user.email,
              org_admin_name: current_user.name,
            )
          end
        end
      end
    end
  end
end
