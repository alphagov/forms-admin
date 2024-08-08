require "rails_helper"

RSpec.describe MailchimpListSynchronizer do
  subject(:mailchimp_list_synchronizer) { described_class }

  before do
    allow($stdout).to receive(:puts)
  end

  describe "#synchronize" do
    let(:mailchimp_client) do
      instance_double(MailchimpMarketing::Client)
    end

    let(:mailchimp_client_lists) do
      instance_double(MailchimpMarketing::ListsApi)
    end

    let(:list_1) do
      {
        "name" => "List 1",
        "stats" => {
          "member_count" => 3,
        },
      }
    end

    let(:list_1_members_info) do
      {
        "members" => [
          { "email_address" => "keep@domain.org" },
          { "email_address" => "archive@domain.org" },
          { "email_address" => "retireduser@domain.org" },
        ],
      }
    end

    let(:users_to_synchronize) do
      [(build :user, email: "subscribe@domain.org"),
       (build :user, email: "keep@domain.org")].pluck(:email)
    end

    before do
      allow(MailchimpMarketing::Client).to receive(:new).and_return(mailchimp_client)

      allow(mailchimp_client).to receive(:set_config)
      allow(mailchimp_client).to receive(:lists).and_return(mailchimp_client_lists)

      allow(mailchimp_client_lists).to receive(:set_list_member)
      allow(mailchimp_client_lists).to receive(:delete_list_member)

      allow(mailchimp_client_lists).to receive(:get_list) do |list_id|
        case list_id
        when "list-1"
          list_1
        else
          raise "Unknown list id"
        end
      end

      allow(mailchimp_client_lists).to receive(:get_list_members_info) do |list_id|
        case list_id
        when "list-1"
          list_1_members_info
        else
          raise "Unknown list id"
        end
      end

      ENV["SETTINGS__MAILCHIMP__API_KEY"] = "KEY"
    end

    it "subscribes users to MailChimp who appear in the database, but not in the mailing list" do
      expect(mailchimp_client_lists).to receive(:set_list_member).with(
        "list-1",
        anything,
        {
          "email_address" => "subscribe@domain.org",
          "status_if_new" => "subscribed",
        },
      )

      described_class.synchronize(list_id: "list-1", users_to_synchronize:)
    end

    it "does not subscribe users who are in the database but lack access to GOV.UK Forms" do
      expect(mailchimp_client_lists).not_to receive(:set_list_member).with(
        "list-1",
        anything,
        {
          "email_address" => "user.without.access@domain.org",
          "status_if_new" => "subscribed",
        },
      )

      described_class.synchronize(list_id: "list-1", users_to_synchronize:)
    end

    it "archives users from MailChimp who do not appear in the database, but do appear in the mailing list" do
      archived_email_hash = Digest::MD5.hexdigest "archive@domain.org"

      expect(mailchimp_client_lists).to receive(:delete_list_member).with("list-1", archived_email_hash)

      described_class.synchronize(list_id: "list-1", users_to_synchronize:)
    end

    it "archives users from MailChimp who exist in the database, but do not have access" do
      archived_email_hash = Digest::MD5.hexdigest "retireduser@domain.org"

      expect(mailchimp_client_lists).to receive(:delete_list_member).with("list-1", archived_email_hash)

      described_class.synchronize(list_id: "list-1", users_to_synchronize:)
    end

    context "when the mailing list has more than 1000 members" do
      let(:list_1) do
        {
          "name" => "List 1",
          "stats" => {
            "member_count" => 1001,
          },
        }
      end

      let(:list_1_members_info) do
        {
          "members" =>
          1001.times.map { { "email_address" => Faker::Internet.unique.email } },
        }
      end

      it "handles all of the results" do
        expect(mailchimp_client_lists).to receive(:delete_list_member).with("list-1", anything).exactly(1001).times

        described_class.synchronize(list_id: "list-1", users_to_synchronize:)
      end
    end
  end
end
