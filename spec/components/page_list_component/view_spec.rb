require "rails_helper"

RSpec.describe PageListComponent::View, type: :component do
  let(:form) { build :form, id: 1 }
  let(:pages) { [] }
  let(:routing_conditions) { [] }
  let(:page_list_component) { described_class.new(pages:, form:) }

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
      let(:pages) { [(build :page, id: 1, position: 1, question_text: "Enter your name?")] }

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

      it "includes the page id in the id for the row" do
        expect(page).to have_css "#page_1.govuk-summary-list__row"
      end
    end

    context "when the form has multiple pages" do
      let(:pages) { [(build :page, id: 1, position: 1, question_text: "Enter your name?"), (build :page, id: 2, position: 2, question_text: "What is you pet's name?")] }

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

      it "includes the page id in the id for each row" do
        expect(page).to have_css "#page_1.govuk-summary-list__row"
        expect(page).to have_css "#page_2.govuk-summary-list__row"
      end

      context "when the form has conditions" do
        let(:pages) do
          [(build :page, id: 1, position: 1, question_text: "What country do you live in?", routing_conditions:),
           (build :page, id: 2, position: 2, question_text: "What is your name?", routing_conditions:),
           (build :page, id: 3, position: 3, question_text: "What is your pet's name?", routing_conditions:)]
        end
        let(:edit_condition_path) { "/forms/0/pages/1/conditions/1" }

        context "when there are no conditions" do
          it "conditions section is not present" do
            expect(page).to have_css(".govuk-summary-list__row", count: pages.length)
          end
        end

        context "when the page has a single condition" do
          let(:routing_conditions) { [(build :condition, id: 1, routing_page_id: 1, check_page_id: 1, answer_value: "Wales", goto_page_id: 3)] }

          it "does not render any errors" do
            expect(page).not_to have_css(".app-page_list__route-text--error")
          end

          it "renders the condition description" do
            condition_description = page_list_component.condition_description(routing_conditions.first)
            expect(condition_description).to be_present
            expect(page).to have_css("dd.govuk-summary-list__value", text: condition_description)
          end

          it "renders the routing details" do
            condition_answer_value_text = I18n.t("page_conditions.condition_answer_value_text", answer_value: "Wales")
            condition_goto_page_text = I18n.t("page_conditions.condition_goto_page_text", goto_page_question_number: 3, goto_page_question_text: "What is your pet's name?")
            expect(page).to have_css("dd.govuk-summary-list__value", text: condition_answer_value_text)
            expect(page).to have_css("dd.govuk-summary-list__value", text: condition_goto_page_text)
          end

          it "renders link" do
            expect(page).to have_link("Edit")
          end
        end

        context "when the page has a condition with no answer_value" do
          let(:routing_conditions) { [(build :condition, :with_answer_value_missing, id: 1, routing_page_id: 1, check_page_id: 1, goto_page_id: 3)] }

          it "renders the errors in an unordered list" do
            condition_answer_value_error = I18n.t("errors.page_conditions.answer_value_doesnt_exist", question_number: 1, route_number: 1)
            expect(page).to have_css("ul > li", text: condition_answer_value_error)
          end

          it "renders the condition description" do
            condition_description = page_list_component.condition_description(routing_conditions.first)
            expect(condition_description).to be_present
            expect(page).to have_css("dd.govuk-summary-list__value", text: condition_description)
          end

          it "renders link" do
            expect(page).to have_link("Edit")
          end
        end

        context "when the page has a condition with no goto_page set" do
          let(:routing_conditions) { [(build :condition, :with_goto_page_missing, id: 1, routing_page_id: 1, check_page_id: 1, answer_value: "Wales")] }

          it "renders the errors in an unordered list" do
            condition_goto_page_error = I18n.t("errors.page_conditions.goto_page_doesnt_exist", question_number: 1)
            expect(page).to have_css("ul > li", text: condition_goto_page_error)
          end

          it "renders the condition description" do
            condition_description = page_list_component.condition_description(routing_conditions.first)
            expect(condition_description).to be_present
            expect(page).to have_css("dd.govuk-summary-list__value", text: condition_description)
          end

          it "renders link" do
            expect(page).to have_link("Edit")
          end

          context "when the condition has an exit page heading" do
            let(:routing_conditions) { [(build :condition, :with_exit_page, id: 1, routing_page_id: 1, check_page_id: 1, answer_value: "Wales")] }

            it "renders the condition description" do
              expect(page).to have_css("dd.govuk-summary-list__value", text: "If “What country do you live in?” is answered as “Wales” go to exit page, “#{routing_conditions.first.exit_page_heading}”")
            end
          end
        end

        context "when the page has a condition with multiple errors" do
          let(:routing_conditions) { [(build :condition, :with_answer_value_and_goto_page_missing, id: 1, routing_page_id: 1, check_page_id: 1)] }

          it "renders the errors in an unordered list" do
            condition_answer_value_error = I18n.t("errors.page_conditions.answer_value_doesnt_exist", question_number: 1, route_number: 1)
            condition_goto_page_error = I18n.t("errors.page_conditions.goto_page_doesnt_exist", question_number: 1, route_number: 1)
            expect(page).to have_css("ul > li", text: condition_answer_value_error)
            expect(page).to have_css("ul > li", text: condition_goto_page_error)
          end

          it "renders link" do
            expect(page).to have_link("Edit")
          end
        end
      end

      context "when the form has a branch route" do
        include_examples "with pages with routing"

        it "renders a summary list row for the any other answer route" do
          expect(page).to have_css("#condition_2.govuk-summary-list__row", text: "Question 2’s routes") do |summary_list_row|
            expect(summary_list_row).to have_link(href: show_routes_path(form_id: 1, page_id: 2)) do |link|
              expect(link).to have_content("Edit Question 2’s routes")
            end
          end
        end

        context "and there is an error with the any other answer route" do
          before do
            branch_any_other_answer_route.has_routing_errors = true
            branch_any_other_answer_route.validation_errors = [OpenStruct.new(name: "cannot_route_to_next_page")]

            render_inline(page_list_component)
          end

          it "renders an error message" do
            error_message = I18n.t("errors.page_conditions.cannot_route_to_next_page", question_number: 2, route_number: "for any other answer")
            expect(page).to have_css ".app-page_list__route-text--error", text: error_message
          end
        end

        context "and the any other answer route skip to question has been moved to before the skip from question" do
          before do
            branch_any_other_answer_route.has_routing_errors = true
            branch_any_other_answer_route.validation_errors = [OpenStruct.new(name: "cannot_have_goto_page_before_routing_page")]

            render_inline(page_list_component)
          end

          it "renders an error message" do
            error_message = I18n.t("errors.page_conditions.any_other_answer_route.cannot_have_goto_page_before_routing_page", question_number: 2, route_number: "for any other answer")
            expect(page).to have_css ".app-page_list__route-text--error", text: error_message
          end
        end
      end
    end
  end

  describe "class methods" do
    let(:pages) do
      [(build :page, id: 1, position: 1, question_text: "What country do you live in?", routing_conditions:),
       (build :page, id: 2, position: 2, question_text: "What is your name?", routing_conditions:),
       (build :page, id: 3, position: 3, question_text: "What is your pet's name?", routing_conditions:)]
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

    describe "#page_row_id" do
      it "returns the corrrect id text for a given page" do
        expect(page_list_component.page_row_id(pages.second)).to eq "page_2"
      end
    end

    describe "error_id" do
      it "returns the corrrect id text for a given condition number" do
        expect(PageListComponent::ErrorSummary::View.error_id(1)).to eq "condition_1"
      end
    end

    describe "#condition_description" do
      let(:pages) do
        [
          (build :page, id: 1, position: 1, question_text: "What country do you live in?", routing_conditions:),
          (build :page, id: 2, position: 2, question_text: "What is your name?", routing_conditions:),
          (build :page, id: 3, position: 3, question_text: "What is your pet's name?", routing_conditions:),
          (build :page, id: 4, position: 4, question_text: "What is your email address?", routing_conditions:),
        ]
      end

      context "when condition has all values set" do
        let(:condition) do
          build(:condition, id: 1,
                            routing_page_id: 1,
                            check_page_id: 1,
                            answer_value: "Wales",
                            goto_page_id: 3)
        end

        it "returns complete condition description" do
          expected_text = "If “What country do you live in?” is answered as “Wales” go to 3, “What is your pet's name?”"
          expect(page_list_component.condition_description(condition)).to eq(expected_text)
        end
      end

      context "when answer value is 'none_of_the_above'" do
        let(:condition) do
          build(:condition,
                id: 1,
                routing_page_id: 1,
                check_page_id: 1,
                answer_value: "none_of_the_above",
                goto_page_id: 3)
        end

        it "returns description with 'None of the above' text" do
          expected_text = "If “What country do you live in?” is answered as “None of the above” go to 3, “What is your pet's name?”"
          expect(page_list_component.condition_description(condition)).to eq(expected_text)
        end
      end

      context "when answer value is missing" do
        let(:condition) do
          build(:condition,
                id: 1,
                routing_page_id: 1,
                check_page_id: 1,
                answer_value: nil,
                goto_page_id: 3)
        end

        it "returns description with error text for missing answer" do
          expected_text = "If “What country do you live in?” is answered as [Answer not selected] go to 3, “What is your pet's name?”"
          expect(page_list_component.condition_description(condition)).to eq(expected_text)
        end
      end

      context "when skip_to_end is true" do
        let(:condition) do
          build(:condition,
                id: 1,
                routing_page_id: 1,
                check_page_id: 1,
                answer_value: "Wales",
                goto_page_id: nil,
                skip_to_end: true)
        end

        it "returns description with 'Check your answers' text" do
          expected_text = "If “What country do you live in?” is answered as “Wales” go to “Check your answers before submitting”."
          expect(page_list_component.condition_description(condition)).to eq(expected_text)
        end
      end

      context "when goto page is missing and skip_to_end is false" do
        let(:condition) do
          build(:condition,
                id: 1,
                routing_page_id: 1,
                check_page_id: 1,
                answer_value: "Wales",
                goto_page_id: nil,
                skip_to_end: false)
        end

        it "returns description with error text for missing goto page" do
          expected_text = "If “What country do you live in?” is answered as “Wales” go to [Question not selected]"
          expect(page_list_component.condition_description(condition)).to eq(expected_text)
        end
      end

      context "when showing a secondary_skip" do
        let(:condition) do
          build(:condition,
                id: 1,
                routing_page_id: 2,
                check_page_id: 1,
                answer_value: nil,
                goto_page_id: 4,
                secondary_skip: true)
        end

        it "returns correct description" do
          expected_text = "After 2, “What is your name?” go to 4, “What is your email address?”"
          expect(page_list_component.condition_description(condition)).to eq(expected_text)
        end
      end
    end
  end
end
