require "rails_helper"

describe GroupMemberMailer, type: :mailer do
  describe "#added_to_group" do
    subject(:mail) do
      described_class.added_to_group(membership, group_url:)
    end

    let(:role) { :editor }
    let(:membership) { create(:membership, role:) }
    let(:group_url) { "group-dot-com" }

    describe "sending an email to a given submission email to check its correct and receiving emails" do
      it "sends an email with the correct template" do
        expect(mail.govuk_notify_template).to eq(Settings.govuk_notify.group_member_added_to_group_id)
      end

      it "sends an email to the new member" do
        expect(mail.to).to eq([membership.user.email])
      end

      it "includes the group path" do
        expect(mail.govuk_notify_personalisation[:group_url]).to eq(group_url)
      end

      it "includes the name of the person who added the new member" do
        expect(mail.govuk_notify_personalisation[:added_by_name]).to eq(membership.added_by.name)
      end

      it "includes the email of the person who added the new member" do
        expect(mail.govuk_notify_personalisation[:added_by_email]).to eq(membership.added_by.email)
      end

      it "includes the group name" do
        expect(mail.govuk_notify_personalisation[:group_name]).to eq(membership.group.name)
      end

      Membership.roles.each_key do |role|
        context "when the role is a #{role}" do
          let(:role) { role }

          it "current role is passed with yes" do
            expect(mail.govuk_notify_personalisation[role.to_sym]).to eq("yes")
          end

          (Membership.roles.keys - [role]).each do |other_role|
            it "#{other_role} are all set to no" do
              expect(mail.govuk_notify_personalisation[other_role.to_sym]).to eq("no")
            end
          end
        end
      end
    end
  end
end
