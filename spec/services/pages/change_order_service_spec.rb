require "rails_helper"

RSpec.describe Pages::ChangeOrderService do
  describe ".generate_new_page_order" do
    let(:pages_to_reorder) { [{ page_id: 101, new_position: nil }, { page_id: 102, new_position: nil }, { page_id: 103, new_position: nil }] }

    it "returns an array of integers" do
      expect(described_class.generate_new_page_order(pages_to_reorder)).to eq([101, 102, 103])
    end

    context "when a page has a new position" do
      let(:pages_to_reorder) { [{ page_id: 101, new_position: 2 }, { page_id: 102, new_position: nil }, { page_id: 103, new_position: nil }] }

      it "returns an array with the page id in that new position" do
        expect(described_class.generate_new_page_order(pages_to_reorder)).to eq([102, 101, 103])
      end
    end

    context "when all pages are assigned a new position" do
      let(:pages_to_reorder) do
        [
          { page_id: 101, new_position: 4 },
          { page_id: 102, new_position: 1 },
          { page_id: 103, new_position: 5 },
          { page_id: 104, new_position: 3 },
          { page_id: 105, new_position: 2 },
        ]
      end

      it "returns an array with the page ids in the new order" do
        expect(described_class.generate_new_page_order(pages_to_reorder)).to eq([102, 105, 104, 101, 103])
      end
    end

    context "when only some pages are assigned a new position" do
      let(:pages_to_reorder) do
        [
          { page_id: 101, new_position: 2 },
          { page_id: 102, new_position: nil },
          { page_id: 103, new_position: 4 },
          { page_id: 104, new_position: 5 },
          { page_id: 105, new_position: nil },
        ]
      end

      it "returns an array with the page id in that new position" do
        expect(described_class.generate_new_page_order(pages_to_reorder)).to eq([102, 101, 105, 103, 104])
      end
    end

    context "when two pages are given the same new position" do
      let(:pages_to_reorder) do
        [
          { page_id: 101, new_position: 3 },
          { page_id: 102, new_position: 3 },
          { page_id: 103, new_position: 4 },
          { page_id: 104, new_position: nil },
          { page_id: 105, new_position: nil },
        ]
      end

      it "puts the first page assigned that position first, followed by the second page assigned the same position" do
        expect(described_class.generate_new_page_order(pages_to_reorder)).to eq([104, 105, 101, 102, 103])
      end
    end

    context "when multiple pages are given the same position at the end of the form" do
      let(:pages_to_reorder) do
        [
          { page_id: 101, new_position: 5 },
          { page_id: 102, new_position: 4 },
          { page_id: 103, new_position: 5 },
          { page_id: 104, new_position: nil },
          { page_id: 105, new_position: nil },
        ]
      end

      it "puts the pages in order of their position, with unassigned pages first" do
        expect(described_class.generate_new_page_order(pages_to_reorder)).to eq([104, 105, 102, 101, 103])
      end
    end
  end
end
