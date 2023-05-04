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
        let(:edit_condition_path) { "/forms/0/pages/1/conditions/1/edit" }

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

        context "when the page has a condition with no answer_value" do
          let(:routing_conditions) { [(build :condition, :with_answer_value_missing, id: 1, routing_page_id: 1, check_page_id: 1, goto_page_id: 3)] }

          it "renders the routing details" do
            condition_check_page_text = I18n.t("page_conditions.condition_check_page_text", check_page_text: pages[0].question_text)
            condition_answer_value_error = I18n.t("page_conditions.errors.answer_value_doesnt_exist", page_index: 1)
            condition_goto_page_text = I18n.t("page_conditions.condition_goto_page_text", goto_page_text: pages[2].question_text)
            expect(page).to have_css("dd.govuk-summary-list__value", text: condition_check_page_text)
            expect(page).to have_link(condition_answer_value_error, href: "#{edit_condition_path}##{Pages::ConditionsForm.new.id_for_field(:answer_value)}")
            expect(page).to have_css("dd.govuk-summary-list__value", text: condition_goto_page_text)
          end

          it "renders link" do
            expect(page).to have_link("Edit")
          end
        end

        context "when the page has a condition with no goto_page set" do
          let(:routing_conditions) { [(build :condition, :with_goto_page_missing, id: 1, routing_page_id: 1, check_page_id: 1, answer_value: "Wales")] }

          it "renders the routing details" do
            condition_check_page_text = I18n.t("page_conditions.condition_check_page_text", check_page_text: pages[0].question_text)
            condition_answer_value_text = I18n.t("page_conditions.condition_answer_value_text", answer_value: "Wales")
            condition_goto_page_error = I18n.t("page_conditions.errors.goto_page_doesnt_exist", page_index: 1)
            expect(page).to have_css("dd.govuk-summary-list__value", text: condition_check_page_text)
            expect(page).to have_css("dd.govuk-summary-list__value", text: condition_answer_value_text)
            expect(page).to have_link(condition_goto_page_error, href: "#{edit_condition_path}##{Pages::ConditionsForm.new.id_for_field(:goto_page_id)}")
          end

          it "renders link" do
            expect(page).to have_link("Edit")
          end
        end

        context "when the page has a condition with no answer value or goto_page set" do
          let(:routing_conditions) { [(build :condition, :with_answer_value_and_goto_page_missing, id: 1, routing_page_id: 1, check_page_id: 1)] }

          it "renders the routing details" do
            condition_check_page_text = I18n.t("page_conditions.condition_check_page_text", check_page_text: pages[0].question_text)
            condition_answer_value_error = I18n.t("page_conditions.errors.answer_value_doesnt_exist", page_index: 1)
            condition_goto_page_error = I18n.t("page_conditions.errors.goto_page_doesnt_exist", page_index: 1)
            expect(page).to have_css("dd.govuk-summary-list__value", text: condition_check_page_text)
            expect(page).to have_link(condition_answer_value_error, href: "#{edit_condition_path}##{Pages::ConditionsForm.new.id_for_field(:answer_value)}")
            expect(page).to have_link(condition_goto_page_error, href: "#{edit_condition_path}##{Pages::ConditionsForm.new.id_for_field(:goto_page_id)}")
          end

          it "renders link" do
            expect(page).to have_link("Edit")
          end
        end
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

    describe "error_id" do
      it "returns the corrrect id text for a given condition number" do
        expect(page_list_component.error_id(1)).to eq "condition_1"
      end
    end

    describe "error_link" do
      let(:condition) { (build :condition, :with_answer_value_missing, id: 1, routing_page_id: 1, check_page_id: 1, goto_page_id: 3) }
      let(:error_name) { condition.validation_errors[0].name }
      let(:condition_edit_path) { "https://example.gov.uk" }
      let(:error_link) { page_list_component.error_link(error_key: error_name, edit_link: condition_edit_path, page_index: 1, field: :answer_value) }

      it "returns the corrrect error html for a given condition" do
        expect(error_link).to eq "<a class=\"govuk-link app-page_list__route-text--error\" href=\"#{condition_edit_path}##{Pages::ConditionsForm.new.id_for_field(:answer_value)}\">#{I18n.t("page_conditions.errors.#{error_name}", page_index: 1)}</a>"
      end
    end

    describe "answer_value_text_for_condition" do
      let(:condition_edit_path) { "https://example.gov.uk" }
      let(:answer_value_text) { page_list_component.answer_value_text_for_condition(condition, condition_edit_path, 1) }

      context "when the answer value is present" do
        let(:condition) { (build :condition, id: 1, routing_page_id: 1, check_page_id: 1, answer_value: "Wales", goto_page_id: 3) }

        it "returns the answer text" do
          expect(answer_value_text).to eq I18n.t("page_conditions.condition_answer_value_text", answer_value: condition.answer_value)
        end
      end

      context "when the answer value is not present" do
        let(:condition) { (build :condition, :with_answer_value_missing, id: 1, routing_page_id: 1, check_page_id: 1, goto_page_id: 3) }

        it "returns the error link" do
          expect(answer_value_text).to eq page_list_component.error_link(error_key: "answer_value_doesnt_exist", edit_link: condition_edit_path, page_index: 1, field: :answer_value)
        end
      end
    end

    describe "goto_page_text_for_condition" do
      let(:condition_edit_path) { "https://example.gov.uk" }
      let(:goto_page_text) { page_list_component.goto_page_text_for_condition(condition, condition_edit_path, 1) }

      context "when the goto page is set" do
        let(:condition) { (build :condition, id: 1, routing_page_id: 1, check_page_id: 1, answer_value: "Wales", goto_page_id: 3) }

        it "returns the goto page text" do
          expect(goto_page_text).to eq I18n.t("page_conditions.condition_goto_page_text", goto_page_text: page_list_component.question_text_for_page(condition.goto_page_id))
        end
      end

      context "when the goto page is not set" do
        let(:condition) { (build :condition, :with_goto_page_missing, id: 1, routing_page_id: 1, check_page_id: 1, answer_value: "Wales") }

        it "returns the goto page error link" do
          expect(goto_page_text).to eq page_list_component.error_link(error_key: "goto_page_doesnt_exist", edit_link: condition_edit_path, page_index: 1, field: :goto_page_id)
        end
      end
    end
  end
end
