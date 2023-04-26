require "rails_helper"

RSpec.describe PageListComponent::View, type: :component do
  let(:pages) { [] }
  let(:routing_conditions) { [] }
  let(:page_list_component) { described_class.new(pages:, form_id: 0) }

  describe "rendering component" do
    before do
      render_inline(page_list_component)
    end

    context "when there are no pages" do
      it "is blank" do
        expect(page).not_to have_selector("*")
      end
    end

    context "when the form has a single page" do
      let(:pages) { [(build :page, id: 1, question_text: "Enter your name?")] }

      it "renders the question number" do
        expect(page).to have_css("dt.govuk-summary-list__key", text: "1")
      end

      it "renders question title" do
        expect(page).to have_content("Enter your name")
      end

      it "renders link" do
        expect(page).to have_link("Edit")
      end

      it "does not have re-ordering buttons" do
        expect(page).not_to have_button("Move up")
        expect(page).not_to have_button("Move down")
      end
    end

    context "when the form has multiple pages" do
      let(:pages) { [(build :page, id: 1, question_text: "Enter your name?"), (build :page, id: 2, question_text: "What is you pet's name?")] }

      it "renders the question numbers" do
        expect(page).to have_css("dt.govuk-summary-list__key", text: "1")
        expect(page).to have_css("dt.govuk-summary-list__key", text: "2")
      end

      it "renders a move up link" do
        expect(page).to have_button("Move up")
      end

      it "renders a move down link" do
        expect(page).to have_button("Move down")
      end

      context "when conditions are enabled", feature_basic_routing: true do
        let(:pages) do
          [(build :page, id: 1, question_text: "What country do you live in?", routing_conditions:),
           (build :page, id: 2, question_text: "What is your name?", routing_conditions:),
           (build :page, id: 3, question_text: "What is your pet's name?", routing_conditions:)]
        end

        context "when there are no conditions" do
          it "conditions section is not present" do
            expect(page).to have_css(".govuk-summary-list__row", count: pages.length)
          end
        end

        context "when the page has a single condition" do
          let(:routing_conditions) { [(build :condition, id: 1, routing_page_id: 1, check_page_id: 1, answer_value: "Wales", goto_page_id: 3)] }

          it "renders the routing details" do
            condition_check_page_text = I18n.t("page_conditions.condition_check_page_text", check_page_text: pages[0].question_text)
            condition_answer_value_text = I18n.t("page_conditions.condition_answer_value_text", answer_value: "Wales")
            condition_goto_page_text = I18n.t("page_conditions.condition_goto_page_text", goto_page_text: pages[2].question_text)
            expect(page).to have_css("dd.govuk-summary-list__value", text: condition_check_page_text)
            expect(page).to have_css("dd.govuk-summary-list__value", text: condition_answer_value_text)
            expect(page).to have_css("dd.govuk-summary-list__value", text: condition_goto_page_text)
          end

          it "renders link" do
            expect(page).to have_link("Edit")
          end
        end

        # TODO: add tests for error cases
      end
    end
  end

  describe "class methods" do
    let(:pages) do
      [(build :page, id: 1, question_text: "What country do you live in?", routing_conditions:),
       (build :page, id: 2, question_text: "What is your name?", routing_conditions:),
       (build :page, id: 3, question_text: "What is your pet's name?", routing_conditions:)]
    end

    describe "show_up_button" do
      it "returns false when index is 0" do
        expect(page_list_component.show_up_button(0)).to be false
      end

      it "returns true when index is not 0" do
        expect(page_list_component.show_up_button(1)).to be true
      end
    end

    describe "show_down_button" do
      it "returns false for the last page in the list" do
        expect(page_list_component.show_down_button(pages.length - 1)).to be false
      end

      it "returns true for other pages" do
        expect(page_list_component.show_down_button(pages.length - 2)).to be true
      end
    end

    describe "question_text_for_page" do
      it "returns the corrrect question text for a page in the form" do
        expect(page_list_component.question_text_for_page(1)).to eq pages[0].question_text
      end
    end
  end
end
