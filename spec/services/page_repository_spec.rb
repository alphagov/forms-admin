require "rails_helper"

describe PageRepository do
  let(:form_id) { form.id }
  let(:form) { create(:form_record) }

  describe "#destroy" do
    let!(:page) { create(:page_record, form_id:) }

    it "removes the page from the database" do
      expect {
        described_class.destroy(page)
      }.to change(Page, :count).by(-1)
    end

    it "returns a page record" do
      expect(described_class.destroy(page)).to be_a(Page)
    end

    context "when the form question section is complete" do
      let(:form) { create(:form_record, question_section_completed: true) }

      it "updates the form to mark the question section as incomplete" do
        expect {
          described_class.destroy(page)
        }.to change { Form.find(form_id).question_section_completed }.to(false)
      end
    end

    context "when the page has routing conditions" do
      before do
        create(:condition_record, routing_page_id: page.id, check_page_id: page.id, goto_page_id: nil, skip_to_end: true, answer_value: "Red")
        create(:condition_record, routing_page_id: page.id, check_page_id: page.id, goto_page_id: nil, skip_to_end: true, answer_value: "Green")
        page.reload
      end

      it "deletes the conditions" do
        expect {
          described_class.destroy(page)
        }.to change(Condition, :count).by(-2)
      end
    end

    it "returns the deleted page" do
      expect(described_class.destroy(page)).to eq page
    end

    context "when the page has already been deleted" do
      it "returns the deleted page" do
        described_class.destroy(page)

        expect(described_class.destroy(page)).to eq page
      end
    end
  end

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
