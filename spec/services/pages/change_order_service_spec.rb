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

  describe ".update_page_order" do
    let(:form) { create(:form, :with_pages, pages_count: 5, question_section_completed:) }
    let(:question_section_completed) { true }
    let(:pages) { form.pages }

    context "when the input array has already been ordered by the new page positions" do
      let(:page_ids_and_positions) do
        [
          { page_id: pages[1].id, new_position: nil },
          { page_id: pages[4].id, new_position: nil },
          { page_id: pages[3].id, new_position: nil },
          { page_id: pages[0].id, new_position: nil },
          { page_id: pages[2].id, new_position: nil },
        ]
      end

      it "updates the page positions to match the new order" do
        expected_order = page_ids_and_positions.map { it[:page_id] }

        described_class.update_page_order(form:, page_ids_and_positions:)
        expect(pages.reload.map(&:id)).to eq(expected_order)
      end

      context "when the form's question_section_completed is true" do
        it "updates question_section_completed to false" do
          expect {
            described_class.update_page_order(form:, page_ids_and_positions:)
          }.to change { form.reload.question_section_completed }.from(true).to(false)
        end

        it "updates the draft form document" do
          described_class.update_page_order(form:, page_ids_and_positions:)
          expect(form.reload.draft_form_document.content["steps"][0]).to include({
            "id" => pages[1].id,
            "next_step_id" => pages[4].id,
          })
        end
      end

      context "when the form's question_section_completed is false" do
        let(:question_section_completed) { false }

        it "updates the draft form document" do
          described_class.update_page_order(form:, page_ids_and_positions:)
          expect(form.reload.draft_form_document.content["steps"][0]).to include({
            "id" => pages[1].id,
            "next_step_id" => pages[4].id,
          })
        end
      end
    end

    context "when the input array has not yet been ordered by the new page positions" do
      let(:page_ids_and_positions) do
        [
          { page_id: pages[0].id, new_position: 4 },
          { page_id: pages[1].id, new_position: 1 },
          { page_id: pages[2].id, new_position: 5 },
          { page_id: pages[3].id, new_position: 3 },
          { page_id: pages[4].id, new_position: 2 },
        ]
      end

      it "calculates the new order and updates the page positions accordingly" do
        expected_order = [pages[1].id, pages[4].id, pages[3].id, pages[0].id, pages[2].id]

        described_class.update_page_order(form:, page_ids_and_positions:)
        expect(pages.reload.map(&:id)).to eq(expected_order)
      end
    end

    context "when a page has been added to the form that does not exist in the input array" do
      let(:page_ids_and_positions) do
        [
          { page_id: pages[1].id, new_position: nil },
          { page_id: pages[3].id, new_position: nil },
          { page_id: pages[0].id, new_position: nil },
          { page_id: pages[2].id, new_position: nil },
        ]
      end

      it "raises an error" do
        expect { described_class.update_page_order(form:, page_ids_and_positions:) }
          .to raise_error Pages::ChangeOrderService::FormPagesAddedError
      end
    end

    context "when a page exists in the input array that has been deleted from the form" do
      let(:non_existent_page_id) { pages.last.id + 1 }
      let(:page_ids_and_positions) do
        [
          { page_id: pages[1].id, new_position: nil },
          { page_id: pages[4].id, new_position: nil },
          { page_id: non_existent_page_id, new_position: nil },
          { page_id: pages[3].id, new_position: nil },
          { page_id: pages[0].id, new_position: nil },
          { page_id: pages[2].id, new_position: nil },
        ]
      end

      it "sets the new order, omitting the deleted page" do
        expected_order = [pages[1].id, pages[4].id, pages[3].id, pages[0].id, pages[2].id]

        described_class.update_page_order(form:, page_ids_and_positions:)
        expect(pages.reload.map(&:id)).to eq(expected_order)
      end
    end

    context "when a page has been added and another page has been deleted from the form" do
      let(:non_existent_page_id) { pages.last.id + 1 }
      let(:page_ids_and_positions) do
        [
          { page_id: pages[1].id, new_position: nil },
          { page_id: pages[3].id, new_position: nil },
          { page_id: pages[0].id, new_position: nil },
          { page_id: pages[2].id, new_position: nil },
          { page_id: non_existent_page_id, new_position: nil },
        ]
      end

      it "raises an error" do
        expect { described_class.update_page_order(form:, page_ids_and_positions:) }
          .to raise_error Pages::ChangeOrderService::FormPagesAddedError
      end
    end
  end
end
