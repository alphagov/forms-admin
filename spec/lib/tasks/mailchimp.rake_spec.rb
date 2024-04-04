require "rake"

require "rails_helper"

RSpec.describe "mailchimp.rake" do
  describe "synchronize_audiences" do
    subject(:task) do
      Rake::Task["mailchimp:synchronize_audiences"]
        .tap(&:reenable)
    end

    let(:mailchimp_client) do
      instance_double("MailchimpMarketing::Client")
    end

    let(:mailchimp_client_lists) do
      instance_double("MailchimpMarketing::ListsApi")
    end

    let(:list_1) do
      {
        "name" => "List 1",
        "stats" => {
          "member_count" => 3,
        },
      }
    end

    let(:list_2) do
      {
        "name" => "List 2",
        "stats" => {
          "member_count" => 3,
        },
      }
    end

    let(:list_1_members_info) do
      {
        "members" => [
          { "email_address" => "keep@domain.org" },
          { "email_address" => "remove@domain.org" },
          { "email_address" => "retireduser@domain.org" },
        ],
      }
    end

    let(:list_2_members_info) do
      {
        "members" => [
          { "email_address" => "keep@domain.org" },
          { "email_address" => "remove@domain.org" },
          { "email_address" => "retireduser@domain.org" },
        ],
      }
    end

    before do
      # Rake.application.options.trace = true

      Rake.application.rake_require "tasks/mailchimp"
      Rake::Task.define_task(:environment)

      create :user, email: "add@domain.org"
      create :user, email: "keep@domain.org"
      create :user, email: "user.without.access@domain.org", has_access: false
      create :user, email: "retireduser@domain.org", has_access: false

      allow(MailchimpMarketing::Client).to receive(:new).and_return(mailchimp_client)

      allow(mailchimp_client).to receive(:set_config)
      allow(mailchimp_client).to receive(:lists).and_return(mailchimp_client_lists)

      allow(mailchimp_client_lists).to receive(:set_list_member)
      allow(mailchimp_client_lists).to receive(:delete_list_member_permanent)

      allow(mailchimp_client_lists).to receive(:get_list) do |list_id|
        case list_id
        when "list-1"
          list_1
        when "list-2"
          list_2
        else
          raise "Unknown list id"
        end
      end

      allow(mailchimp_client_lists).to receive(:get_list_members_info) do |list_id|
        case list_id
        when "list-1"
          list_1_members_info
        when "list-2"
          list_2_members_info
        else
          raise "Unknown list id"
        end
      end

      ENV["SETTINGS__MAILCHIMP__API_KEY"] = "KEY"
    end

    it "adds users to MailChimp who appear in the database, but not in the mailing list" do
      expect(mailchimp_client_lists).to receive(:set_list_member).with(
        "list-1",
        anything,
        {
          "email_address" => "add@domain.org",
          "status_if_new" => "subscribed",
        },
      )

      expect(mailchimp_client_lists).to receive(:set_list_member).with(
        "list-2",
        anything,
        {
          "email_address" => "add@domain.org",
          "status_if_new" => "subscribed",
        },
      )

      expect { task.invoke }.to output.to_stdout
    end

    it "does not add users who are into the database but lack access to GOV.UK Forms" do
      expect(mailchimp_client_lists).not_to receive(:set_list_member).with(
        "list-1",
        anything,
        {
          "email_address" => "user.without.access@domain.org",
          "status_if_new" => "subscribed",
        },
      )

      expect(mailchimp_client_lists).not_to receive(:set_list_member).with(
        "list-2",
        anything,
        {
          "email_address" => "user.without.access@domain.org",
          "status_if_new" => "subscribed",
        },
      )

      expect { task.invoke }.to output.to_stdout
    end

    it "removes users from MailChimp who do not appear in the database, but do appear in the mailing list" do
      removed_email_hash = Digest::MD5.hexdigest "remove@domain.org"

      expect(mailchimp_client_lists).to receive(:delete_list_member_permanent).with("list-1", removed_email_hash)
      expect(mailchimp_client_lists).to receive(:delete_list_member_permanent).with("list-2", removed_email_hash)

      expect { task.invoke }.to output.to_stdout
    end

    it "removes users from MailChimp who exist in the database, but do not have access" do
      removed_email_hash = Digest::MD5.hexdigest "retireduser@domain.org"

      expect(mailchimp_client_lists).to receive(:delete_list_member_permanent).with("list-1", removed_email_hash)
      expect(mailchimp_client_lists).to receive(:delete_list_member_permanent).with("list-2", removed_email_hash)

      expect { task.invoke }.to output.to_stdout
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
          1001.times.map { { "email_address" => Faker::Internet.email } },
        }
      end

      it "handles all of the results" do
        expect(mailchimp_client_lists).to receive(:delete_list_member_permanent).with("list-1", anything).exactly(1001).times

        expect { task.invoke }.to output.to_stdout
      end
    end
  end
end
