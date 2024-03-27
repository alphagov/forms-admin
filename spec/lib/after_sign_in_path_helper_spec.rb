require "rails_helper"

describe AfterSignInPathHelper do
  include Rails.application.routes.url_helpers

  subject(:path_helper) { described_class.new(user, default_path:) }

  let(:user) { build :user }
  let(:default_path) { "/default" }

  describe "#next_path" do
    context "when the user has an organisation and name" do
      it "returns the default path" do
        expect(path_helper.next_path).to eq default_path
      end
    end

    context "when the user does not have an organisation" do
      let(:user) { build :user, :with_no_org }

      it "returns the path to edit the organisation" do
        expect(path_helper.next_path).to eq edit_account_organisation_path
      end
    end

    context "when the user does not have a name" do
      let(:user) { build :user, name: nil }

      it "returns the path to edit the name" do
        expect(path_helper.next_path).to eq edit_account_name_path
      end
    end
  end
end
