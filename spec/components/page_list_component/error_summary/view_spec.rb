require "rails_helper"

RSpec.describe PageListComponent::ErrorSummary::View, type: :component do
  let(:pages) { [] }
  let(:routing_conditions) { [] }
  let(:error_summary_component) { described_class.new(pages:) }

  describe "rendering component" do
    before do
      render_inline(error_summary_component)
    end

    context "when there are no pages" do
      it "is blank" do
        expect(page).not_to have_selector("*")
      end
    end

    context "when there are no errors" do
      let(:routing_conditions) do
        [(build :condition, id: 1, routing_page_id: 1, check_page_id: 1, answer_value: "Wales", goto_page_id: 3),
         (build :condition, id: 2, routing_page_id: 1, check_page_id: 1, answer_value: "England", goto_page_id: 2)]
      end
      let(:pages) do
        [(build :page, id: 1, position: 1, question_text: "Enter your name", routing_conditions:),
         (build :page, id: 2, position: 2, question_text: "What is your pet's phone number?", routing_conditions: []),
         (build :page, id: 3, position: 3, question_text: "How many pets do you own?", routing_conditions: [])]
      end

      it "is blank" do
        expect(page).not_to have_selector("*")
      end
    end

    context "when the form has a route with an error" do
      let(:routing_conditions) do
        [(build :condition, :with_answer_value_missing, id: 1, routing_page_id: 1, check_page_id: 1, goto_page_id: 3),
         (build :condition, id: 2, routing_page_id: 1, check_page_id: 1, answer_value: "England", goto_page_id: 2)]
      end
      let(:pages) do
        [(build :page, id: 1, position: 1, question_text: "Enter your name", routing_conditions:),
         (build :page, id: 2, position: 2, question_text: "What is your pet's phone number?", routing_conditions: []),
         (build :page, id: 3, position: 3, question_text: "How many pets do you own?", routing_conditions: [])]
      end

      it "renders the error_summary" do
        expect(page).to have_css(".govuk-error-summary")
      end

      it "renders the error link" do
        condition_answer_value_error = I18n.t("errors.page_conditions.answer_value_doesnt_exist", question_number: 1, route_number: 1)
        expect(page).to have_link(condition_answer_value_error, href: "##{described_class.error_id(routing_conditions[0].id)}")
      end
    end

    context "when the form has multiple routes with errors" do
      let(:routing_conditions_page_with_answer_value_missing) do
        [(build :condition, :with_answer_value_missing, id: 1, routing_page_id: 1, check_page_id: 1, goto_page_id: 3)]
      end
      let(:routing_conditions_page_with_goto_page_missing) do
        [(build :condition, :with_goto_page_missing, id: 2, routing_page_id: 2, check_page_id: 2, answer_value: "Wales")]
      end
      let(:pages) do
        [(build :page, id: 1, position: 1, question_text: "Enter your name", routing_conditions: routing_conditions_page_with_answer_value_missing),
         (build :page, id: 2, position: 2, question_text: "What is your pet's phone number?", routing_conditions: routing_conditions_page_with_goto_page_missing),
         (build :page, id: 3, position: 3, question_text: "How many pets do you own?", routing_conditions: [])]
      end

      it "renders the error_summary" do
        expect(page).to have_css(".govuk-error-summary")
      end

      it "renders both error links" do
        condition_answer_value_error = I18n.t("errors.page_conditions.answer_value_doesnt_exist", question_number: 1, route_number: 1)
        condition_goto_page_error = I18n.t("errors.page_conditions.goto_page_doesnt_exist", question_number: 2, route_number: 1)
        expect(page).to have_link(condition_answer_value_error, href: "##{described_class.error_id(routing_conditions_page_with_answer_value_missing[0].id)}")
        expect(page).to have_link(condition_goto_page_error, href: "##{described_class.error_id(routing_conditions_page_with_goto_page_missing[0].id)}")
      end
    end

    context "when the form has a branch route" do
      include_examples "with pages with routing"

      context "and there is an error with the any other answer route" do
        before do
          branch_any_other_answer_route.has_routing_errors = true
          branch_any_other_answer_route.validation_errors = [OpenStruct.new(name: "cannot_route_to_next_page")]

          render_inline(error_summary_component)
        end

        it "renders the error summary" do
          error_message = I18n.t("errors.page_conditions.cannot_route_to_next_page", question_number: 2, route_number: "for any other answer")
          expect(page).to have_css ".govuk-error-summary", text: error_message
          expect(page).to have_link error_message, href: "#condition_#{branch_any_other_answer_route.id}"
        end
      end

      context "and the any other answer route skip to question has been moved to before the skip from question" do
        before do
          branch_any_other_answer_route.has_routing_errors = true
          branch_any_other_answer_route.validation_errors = [OpenStruct.new(name: "cannot_have_goto_page_before_routing_page")]

          render_inline(error_summary_component)
        end

        it "renders an error message" do
          error_message = I18n.t("errors.page_conditions.any_other_answer_route.cannot_have_goto_page_before_routing_page", question_number: 2, route_number: "for any other answer")
          expect(page).to have_css ".govuk-error-summary", text: error_message
          expect(page).to have_link error_message, href: "#condition_#{branch_any_other_answer_route.id}"
        end
      end
    end
  end

  describe "class methods" do
    let(:routing_conditions_page_with_answer_value_missing) do
      [(build :condition, :with_answer_value_missing, id: 1, routing_page_id: 1, check_page_id: 1, goto_page_id: 3)]
    end
    let(:routing_conditions_page_with_goto_page_missing) do
      [(build :condition, :with_goto_page_missing, id: 2, routing_page_id: 2, check_page_id: 2, answer_value: "Wales")]
    end
    let(:pages) do
      [(build :page, id: 1, position: 1, question_text: "Enter your name", routing_conditions: routing_conditions_page_with_answer_value_missing),
       (build :page, id: 2, position: 2, question_text: "What is your pet's phone number?", routing_conditions: routing_conditions_page_with_goto_page_missing),
       (build :page, id: 3, position: 3, question_text: "How many pets do you own?", routing_conditions: [])]
    end

    describe "#error_id" do
      it "returns the correct id value" do
        expect(described_class.error_id(1)).to eq "condition_1"
      end
    end

    describe "#error_object" do
      it "returns an error object in the correct format" do
        condition = build :condition, id: 1
        page = build :page, position: 1
        expect(error_summary_component.error_object(error_name: "answer_value_doesnt_exist", condition:, page:)).to eq OpenStruct.new(message: I18n.t("errors.page_conditions.answer_value_doesnt_exist", question_number: 1, route_number: 1), link: "##{described_class.error_id(1)}")
      end
    end

    describe "#conditions_with_check_pages" do
      it "returns all of the conditions for a form with their respective conditions and check pages" do
        expect(error_summary_component.conditions_with_check_pages).to match [
          an_object_having_attributes(id: routing_conditions_page_with_answer_value_missing[0].id, check_page: pages.first),
          an_object_having_attributes(id: routing_conditions_page_with_goto_page_missing[0].id, check_page: pages.second),
        ]
      end

      context "when the form has branch routing" do
        include_context "with pages with routing"

        it "returns all of the conditions for a form with their respective conditions and check pages" do
          expect(error_summary_component.conditions_with_check_pages).to match [
            an_object_having_attributes(id: branch_route_1.id, check_page: page_with_skip_and_secondary_skip),
            an_object_having_attributes(id: branch_any_other_answer_route.id, check_page: page_with_skip_and_secondary_skip),
            an_object_having_attributes(id: skip_route.id, check_page: page_with_skip_route),
            an_object_having_attributes(id: exit_page.id, check_page: page_with_exit_page),
          ]
        end
      end
    end

    describe "#errors_for_summary" do
      it "returns all of the routing errors for a form with their respective positions and links" do
        expect(error_summary_component.errors_for_summary).to eq [
          OpenStruct.new(message: I18n.t("errors.page_conditions.answer_value_doesnt_exist", question_number: 1, route_number: 1), link: "##{described_class.error_id(1)}"),
          OpenStruct.new(message: I18n.t("errors.page_conditions.goto_page_doesnt_exist", question_number: 2, route_number: 1), link: "##{described_class.error_id(2)}"),
        ]
      end
    end
  end
end
