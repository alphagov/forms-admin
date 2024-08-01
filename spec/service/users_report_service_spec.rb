require "rails_helper"

describe UsersReportService do
  subject(:users_report_service) do
    described_class.new
  end

  describe "#user_data" do
    it "returns the correct format" do
      expect(users_report_service.user_data).to match({
        caption: I18n.t("reports.users.heading"),
        head: [
          { text: I18n.t("reports.users.table_headings.organisation_name") },
          { text: I18n.t("reports.users.table_headings.user_count"), numeric: true },
        ],
        rows: [],
      })
    end

    context "with orgs and users" do
      it "returns the correct rows" do
        org1 = create :organisation, slug: "with-most-users"
        org2 = create :organisation, slug: "with-one-user"
        create :organisation, slug: "with-no-users"
        create :user, organisation: org1
        create :user, organisation: org1
        create :user, organisation: org2
        create :user, :with_no_org
        expect(users_report_service.user_data[:rows]).to eq([
          [{ text: org1.name }, { text: 2, numeric: true }],
          [{ text: org2.name }, { text: 1, numeric: true }],
          [{ text: I18n.t("users.index.organisation_blank") }, { text: 1, numeric: true }],
        ])
      end
    end
  end
end
