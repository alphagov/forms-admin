require "rails_helper"

describe PageRepository do
  let(:form_id) { form.id }
  let(:form) { create(:form_record) }

  describe "#move_page" do
    let(:form) { create(:form_record, :with_pages) }
    let(:page) { form.pages.second }

    it "updates the page in the database" do
      expect {
        described_class.move_page(page, :up)
      }.to change { Page.find(page.id).position }.from(2).to(1)
    end

    it "returns a page record" do
      expect(described_class.move_page(page, :up)).to be_a(Page)
    end
  end
end
