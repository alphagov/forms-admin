require "rails_helper"

describe Reports::ContactForResearchService do
  subject(:contact_for_research_service) do
    described_class.new
  end

  describe "#contact_for_research_data" do
    it "returns the correct format" do
      expect(contact_for_research_service.contact_for_research_data).to match({
        caption: I18n.t("reports.contact_for_research.heading"),
        head: [
          { text: I18n.t("reports.contact_for_research.table_headings.name") },
          { text: I18n.t("reports.contact_for_research.table_headings.email") },
          { text: I18n.t("reports.contact_for_research.table_headings.date_added") },
        ],
        rows: [],
      })
    end

    context "with users" do
      it "returns the correct rows" do
        create :user, research_contact_status: :consented, user_research_opted_in_at: Time.zone.local(2024, 6, 1, 15, 30), name: "Middle", email: "test@example.gov.uk"
        create :user, research_contact_status: :consented, user_research_opted_in_at: Time.zone.local(2025, 2, 1, 11, 15), name: "Top", email: "ur@another.gov.uk"
        create :user, research_contact_status: :consented, user_research_opted_in_at: Time.zone.local(2023, 4, 1, 9, 45), name: "Bottom", email: "last@example.gov.uk"
        create :user, research_contact_status: :to_be_asked
        create :user, research_contact_status: :declined

        expect(contact_for_research_service.contact_for_research_data[:rows]).to eq([
          [{ text: "Top" }, { text: "ur@another.gov.uk" }, { text: "February 01, 2025 11:15" }],
          [{ text: "Middle" }, { text: "test@example.gov.uk" }, { text: "June 01, 2024 15:30" }],
          [{ text: "Bottom" }, { text: "last@example.gov.uk" }, { text: "April 01, 2023 09:45" }],
        ])
      end
    end
  end
end
