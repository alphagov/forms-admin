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
          "member_count" => 1,
          "total_contacts" => 1,
        },
      }
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

    RSpec.shared_examples "it subscribes the user" do
      it "subscribes the user" do
        expect(mailchimp_client_lists).to receive(:set_list_member).with(
          "list-1",
          anything,
          {
            "email_address" => "user@domain.org",
            "status" => "subscribed",
          },
        )

        described_class.synchronize(list_id: "list-1", users_to_synchronize:)
      end
    end

    RSpec.shared_examples "it archives the user" do
      it "archives the user" do
        archived_email_hash = Digest::MD5.hexdigest "user@domain.org"

        expect(mailchimp_client_lists).to receive(:delete_list_member).with("list-1", archived_email_hash)

        described_class.synchronize(list_id: "list-1", users_to_synchronize:)
      end
    end

    RSpec.shared_examples "it does not subscribe or archive the user" do
      it "does not subscribe or archive the user" do
        expect(mailchimp_client_lists).not_to receive(:set_list_member)
        expect(mailchimp_client_lists).not_to receive(:delete_list_member)

        described_class.synchronize(list_id: "list-1", users_to_synchronize:)
      end
    end

    RSpec.shared_examples "it does not subscribe or archive the user in question" do
      it "subscribes other users in the list, but not the current user" do
        # the API should only receive one subscribe request, for a different email address
        expect(mailchimp_client_lists).to receive(:set_list_member).once do |_list_id, _subscriber_hash, body|
          expect(body["email_address"]).to eq("some_other_user@domain.org")
        end

        described_class.synchronize(list_id: "list-1", users_to_synchronize:)
      end

      it "does not archive the user" do
        expect(mailchimp_client_lists).not_to receive(:delete_list_member)

        described_class.synchronize(list_id: "list-1", users_to_synchronize:)
      end
    end

    context "when the user is in the list of users to synchronize" do
      let(:users_to_synchronize) { ["user@domain.org"] }

      context "when the user is not present in the MailChimp list" do
        let(:list_1_members_info) do
          {
            "members" => [],
          }
        end

        include_examples "it subscribes the user"
      end

      context "when the user is subscribed in MailChimp" do
        let(:list_1_members_info) do
          {
            "members" => [
              { "email_address" => "user@domain.org", "status" => "subscribed" },
            ],
          }
        end

        include_examples "it does not subscribe or archive the user"
      end

      context "when the user is unsubscribed in MailChimp" do
        let(:list_1_members_info) do
          {
            "members" => [
              { "email_address" => "user@domain.org", "status" => "unsubscribed" },
            ],
          }
        end

        include_examples "it does not subscribe or archive the user"
      end

      context "when the user is archived in MailChimp" do
        let(:list_1_members_info) do
          {
            "members" => [
              { "email_address" => "user@domain.org", "status" => "archived" },
            ],
          }
        end

        include_examples "it subscribes the user"
      end

      context "when the user is 'cleaned' in MailChimp" do
        let(:list_1_members_info) do
          {
            "members" => [
              { "email_address" => "user@domain.org", "status" => "cleaned" },
            ],
          }
        end

        include_examples "it subscribes the user"
      end

      context "when the user is 'pending' in MailChimp" do
        let(:list_1_members_info) do
          {
            "members" => [
              { "email_address" => "user@domain.org", "status" => "pending" },
            ],
          }
        end

        include_examples "it subscribes the user"
      end

      context "when the user is 'transactional' in MailChimp" do
        let(:list_1_members_info) do
          {
            "members" => [
              { "email_address" => "user@domain.org", "status" => "transactional" },
            ],
          }
        end

        include_examples "it subscribes the user"
      end
    end

    context "when the user is not in the list of users to synchronize" do
      let(:users_to_synchronize) { ["some_other_user@domain.org"] }

      context "when the user is not present in the MailChimp list" do
        let(:list_1_members_info) do
          {
            "members" => [],
          }
        end

        include_examples "it does not subscribe or archive the user in question"
      end

      context "when the user is subscribed in MailChimp" do
        let(:list_1_members_info) do
          {
            "members" => [
              { "email_address" => "user@domain.org", "status" => "subscribed" },
            ],
          }
        end

        include_examples "it archives the user"
      end

      context "when the user is unsubscribed in MailChimp" do
        let(:list_1_members_info) do
          {
            "members" => [
              { "email_address" => "user@domain.org", "status" => "unsubscribed" },
            ],
          }
        end

        include_examples "it does not subscribe or archive the user in question"
      end

      context "when the user is archived in MailChimp" do
        let(:list_1_members_info) do
          {
            "members" => [
              { "email_address" => "user@domain.org", "status" => "archived" },
            ],
          }
        end

        include_examples "it does not subscribe or archive the user in question"
      end

      context "when the user is 'cleaned' in MailChimp" do
        let(:list_1_members_info) do
          {
            "members" => [
              { "email_address" => "user@domain.org", "status" => "cleaned" },
            ],
          }
        end

        include_examples "it archives the user"
      end

      context "when the user is 'pending' in MailChimp" do
        let(:list_1_members_info) do
          {
            "members" => [
              { "email_address" => "user@domain.org", "status" => "pending" },
            ],
          }
        end

        include_examples "it archives the user"
      end

      context "when the user is 'transactional' in MailChimp" do
        let(:list_1_members_info) do
          {
            "members" => [
              { "email_address" => "user@domain.org", "status" => "transactional" },
            ],
          }
        end

        include_examples "it archives the user"
      end
    end

    context "when the mailing list has more than 1000 members" do
      let(:users_to_synchronize) do
        ["some_email_address@domain.org"]
      end

      let(:list_1) do
        {
          "name" => "List 1",
          "stats" => {
            "member_count" => 995,
            "total_contacts" => 1001,
          },
        }
      end

      let(:list_1_members_info) do
        {
          "members" =>
          1001.times.map { { "email_address" => Faker::Internet.unique.email, "status" => "subscribed" } },
        }
      end

      it "handles all of the results" do
        expect(mailchimp_client_lists).to receive(:delete_list_member).with("list-1", anything).exactly(1001).times

        described_class.synchronize(list_id: "list-1", users_to_synchronize:)
      end
    end
  end
end
