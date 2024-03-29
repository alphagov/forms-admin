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

    before do
      # Rake.application.options.trace = true

      Rake.application.rake_require "tasks/mailchimp"
      Rake::Task.define_task(:environment)

      create :user, email: "add@domain.org"
      create :user, email: "keep@domain.org"

      allow(MailchimpMarketing::Client).to receive(:new).and_return(mailchimp_client)

      allow(mailchimp_client).to receive(:set_config)
      allow(mailchimp_client).to receive(:lists).and_return(mailchimp_client_lists)

      allow(mailchimp_client_lists).to receive(:set_list_member)
      allow(mailchimp_client_lists).to receive(:delete_list_member_permanent)

      allow(mailchimp_client_lists).to receive(:get_list) do |list_id|
        case list_id
        when "list-1"
          {
            "name" => "List 1",
            "stats" => {
              "member_count" => 2,
            },
          }
        when "list-2"
          {
            "name" => "List 2",
            "stats" => {
              "member_count" => 2,
            },
          }
        else
          raise "Unknown list id"
        end
      end

      allow(mailchimp_client_lists).to receive(:get_list_members_info) do |list_id|
        case list_id
        when "list-1"
          {
            "members" => [
              { "email_address" => "keep@domain.org" },
              { "email_address" => "remove@domain.org" },
            ],
          }
        when "list-2"
          {
            "members" => [
              { "email_address" => "keep@domain.org" },
              { "email_address" => "remove@domain.org" },
            ],
          }
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

    it "removes users from MailChimp who do not appear in the database, but do appear in the mailing list" do
      removed_email_hash = Digest::MD5.hexdigest "remove@domain.org"

      expect(mailchimp_client_lists).to receive(:delete_list_member_permanent).with("list-1", removed_email_hash)
      expect(mailchimp_client_lists).to receive(:delete_list_member_permanent).with("list-2", removed_email_hash)

      expect { task.invoke }.to output.to_stdout
    end
  end
end
