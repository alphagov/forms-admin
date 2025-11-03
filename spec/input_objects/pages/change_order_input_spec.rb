require "rails_helper"

RSpec.describe Pages::ChangeOrderInput, type: :model do
  subject(:change_order_input) { described_class.new(form:, page_position_params:, confirm:) }

  let(:form) { create :form, :with_pages, pages_count: 3 }
  let(:confirm) { nil }
  let(:page_position_params) do
    {
      "position_for_page_#{form.pages[0].id}" => "2",
      "position_for_page_#{form.pages[1].id}" => "1",
      "position_for_page_#{form.pages[2].id}" => "",
    }
  end

  describe "validations" do
    describe "#validate_positions" do
      context "when all the positions are within allowed range" do
        let(:page_position_params) do
          {
            "position_for_page_#{form.pages[0].id}" => "1000",
            "position_for_page_#{form.pages[1].id}" => "1",
            "position_for_page_#{form.pages[2].id}" => "",
          }
        end

        it "is valid" do
          expect(change_order_input.valid?(:preview)).to be(true)
        end
      end

      context "when a position is below the allowed range" do
        let(:page_position_params) { { "position_for_page_#{form.pages[0].id}" => "0" } }

        it "is not valid" do
          error_message = I18n.t("activemodel.errors.models.pages/change_order_input.attributes.page_position.invalid", maximum: 1000)
          expect(change_order_input.valid?(:preview)).to be(false)
          expect(change_order_input.errors.full_messages_for(page_position_params.keys[0])).to include("Position for page #{form.pages[0].id} #{error_message}")
        end
      end

      context "when a position is above the allowed range" do
        let(:page_position_params) { { "position_for_page_#{form.pages[0].id}" => "1001" } }

        it "is not valid" do
          error_message = I18n.t("activemodel.errors.models.pages/change_order_input.attributes.page_position.invalid", maximum: 1000)
          expect(change_order_input.valid?(:preview)).to be(false)
          expect(change_order_input.errors.full_messages_for(page_position_params.keys[0])).to include("Position for page #{form.pages[0].id} #{error_message}")
        end
      end

      context "when a given position value is not a number" do
        let(:page_position_params) { { "position_for_page_#{form.pages[0].id}" => "not a number" } }

        it "is not valid" do
          error_message = I18n.t("activemodel.errors.models.pages/change_order_input.attributes.page_position.invalid", maximum: 1000)
          expect(change_order_input.valid?(:preview)).to be(false)
          expect(change_order_input.errors.full_messages_for(page_position_params.keys[0])).to include("Position for page #{form.pages[0].id} #{error_message}")
        end
      end
    end

    describe "confirm validation" do
      context "when in a preview context" do
        let(:confirm) { nil }

        it "is valid when confirm value is not present" do
          expect(change_order_input.valid?(:preview)).to be(true)
        end
      end

      context "when not in a preview context" do
        context "when confirm is nil" do
          let(:confirm) { nil }

          it "is not valid" do
            error_message = "Confirm Select ‘Yes, save this question order’ to save your changes"
            expect(change_order_input).to be_invalid
            expect(change_order_input.errors.full_messages_for(:confirm)).to include(error_message)
          end
        end

        context "when confirm is not in the radio options" do
          let(:confirm) { "ok" }

          it "is not valid" do
            error_message = "Confirm Select ‘Yes, save this question order’ to save your changes"
            expect(change_order_input).to be_invalid
            expect(change_order_input.errors.full_messages_for(:confirm)).to include(error_message)
          end
        end

        context "when confirm is one of the radio options" do
          let(:confirm) { "yes" }

          it "is valid" do
            expect(change_order_input).to be_valid
          end
        end
      end
    end
  end

  describe "#update_preview" do
    let(:page_position_params) do
      { "position_for_page_#{form.pages[0].id}" => "2",
        "position_for_page_#{form.pages[1].id}" => "1" }
    end

    it "calls the ChangeOrderService with generate_new_page_order" do
      page_ids_and_positions = [
        { page_id: form.pages[0].id, new_position: "2" },
        { page_id: form.pages[1].id, new_position: "1" },
      ]

      expect(Pages::ChangeOrderService).to receive(:generate_new_page_order).with(page_ids_and_positions).and_call_original
      change_order_input.update_preview
    end

    it "clears the page_position_params" do
      expect {
        change_order_input.update_preview
      }.to change(change_order_input, :page_position_params).to(nil)
    end
  end

  describe "#submit" do
    context "when the input object is invalid" do
      let(:confirm) { "not ok" }

      it "returns false" do
        expect(change_order_input.submit).to be(false)
      end
    end

    context "when the input object is valid" do
      context "when confirm is 'yes'" do
        let(:confirm) { "yes" }

        it "calls the ChangeOrderService with update_page_order" do
          page_ids_and_positions = [
            { page_id: form.pages[0].id, new_position: "2" },
            { page_id: form.pages[1].id, new_position: "1" },
            { page_id: form.pages[2].id, new_position: "" },
          ]

          expect(Pages::ChangeOrderService).to receive(:update_page_order).with(form:, page_ids_and_positions: page_ids_and_positions).and_call_original
          change_order_input.submit
        end

        it "returns true" do
          expect(change_order_input.submit).to be(true)
        end
      end

      context "when confirm is 'no'" do
        let(:confirm) { "no" }

        it "does not call the ChangeOrderService" do
          expect(Pages::ChangeOrderService).not_to receive(:update_page_order)
          change_order_input.submit
        end

        it "returns true" do
          expect(change_order_input.submit).to be(true)
        end
      end
    end
  end

  describe "#pages" do
    context "when the preview has been updated" do
      it "returns the pages in the new order" do
        change_order_input.update_preview

        expect(change_order_input.pages).to eq([form.pages[1], form.pages[0], form.pages[2]])
      end

      context "when there is a page that no longer exists in the form" do
        before do
          form.pages[2].delete
          change_order_input.update_preview
        end

        it "returns the pages in the new order without the missing page" do
          expect(change_order_input.pages).to eq([form.pages[1], form.pages[0]])
        end
      end
    end

    context "when loading the starting page order" do
      let(:page_position_params) { nil }

      it "returns the pages in the order they are in the form" do
        expect(change_order_input.pages).to eq(form.pages)
      end
    end

    context "when there were errors updating the page order" do
      let(:page_position_params) do
        {
          "position_for_page_#{form.pages[1].id}" => "0",
          "position_for_page_#{form.pages[2].id}" => "",
          "position_for_page_#{form.pages[0].id}" => "2",
        }
      end

      it "returns pages in the order they are sequenced in the params" do
        expect(change_order_input.pages).to eq([form.pages[1], form.pages[2], form.pages[0]])
      end
    end
  end
end
