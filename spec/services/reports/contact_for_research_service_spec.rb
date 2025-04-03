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
        create :user, research_contact_status: :consented, created_at: Time.zone.local(2024, 6, 1), name: "Middle", email: "test@example.gov.uk"
        create :user, research_contact_status: :consented, created_at: Time.zone.local(2025, 2, 1), name: "Top", email: "ur@another.gov.uk"
        create :user, research_contact_status: :consented, created_at: Time.zone.local(2023, 4, 1), name: "Bottom", email: "last@example.gov.uk"
        create :user, research_contact_status: :not_asked
        create :user, research_contact_status: :to_be_asked
        create :user, research_contact_status: :declined

        expect(contact_for_research_service.contact_for_research_data[:rows]).to eq([
          [{ text: "Top" }, { text: "ur@another.gov.uk" }, { text: "1 February 2025" }],
          [{ text: "Middle" }, { text: "test@example.gov.uk" }, { text: "1 June 2024" }],
          [{ text: "Bottom" }, { text: "last@example.gov.uk" }, { text: "1 April 2023" }],
        ])
      end
    end
  end
end
