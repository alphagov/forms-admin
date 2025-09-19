require "rails_helper"

RSpec.describe Users::CsvService do
  let(:organisation) { create(:organisation, :with_org_admin) }
  let(:users) do
    create_list(:user, 3, organisation:, role: "organisation_admin")
  end

  describe "#csv" do
    subject(:csv_rows) do
      csv = described_class.new(users).csv
      CSV.parse(csv)
    end

    it "returns a CSV with a header row and a row for each user" do
      expect(csv_rows.length).to eq(4)
    end

    it "has expected values" do
      expect(csv_rows[1]).to contain_exactly(
        users.first.name,
        users.first.email,
        organisation.name,
        organisation.id.to_s,
        "Organisation admin",
        "Permitted",
        users.first.terms_agreed_at.to_s,
        users.first.created_at.to_s,
        users.first.last_signed_in_at.to_s,
      )
    end

    context "when user has no name set" do
      let(:users) { [create(:user, :with_no_name)] }

      it "shows no name set" do
        expect(csv_rows[1][0]).to eq "No name set"
      end
    end

    context "when user has no organisation set" do
      let(:users) { [create(:user, :with_no_org)] }

      it "shows no name set" do
        expect(csv_rows[1][2]).to eq "No organisation set"
      end
    end
  end
end
