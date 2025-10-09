require "rails_helper"

RSpec.describe PageListComponent::ErrorSummary::View, type: :component do
  let(:form) { create :form }
  let(:pages) { form.reload.pages }
  let(:error_summary_component) { described_class.new(form) }

  describe "rendering component" do
    context "when there are no pages" do
      it "is blank" do
        render_inline(error_summary_component)

        expect(page).not_to have_selector("*")
      end
    end

    context "when there are no conditions with errors" do
      let(:form) { create :form, :ready_for_routing }

      before do
        create :condition, routing_page_id: pages.first.id, check_page_id: pages.first.id, answer_value: "Option 1", goto_page_id: pages.last.id
        pages.first.reload
      end

      it "is blank" do
        render_inline(error_summary_component)

        expect(page).not_to have_selector("*")
      end
    end

    context "when the form has a route with an error" do
      let(:form) { create :form, :ready_for_routing }
      let!(:condition) { create :condition, routing_page_id: pages.first.id, check_page_id: pages.first.id, answer_value: nil, goto_page_id: pages.last.id }

      before do
        pages.first.reload
      end

      it "renders the error_summary" do
        render_inline(error_summary_component)

        expect(page).to have_css(".govuk-error-summary")
      end

      it "renders the error link" do
        render_inline(error_summary_component)

        condition_answer_value_error = I18n.t("errors.page_conditions.answer_value_doesnt_exist", question_number: 1, route_number: 1)
        expect(page).to have_link(condition_answer_value_error, href: "##{described_class.error_id(condition.id)}")
      end
    end

    context "when the form has multiple routes with errors" do
      let(:form) { create :form, :ready_for_routing }
      let!(:condition_with_answer_value_missing) { create :condition, routing_page_id: pages.first.id, check_page_id: pages.first.id, goto_page_id: pages.third.id, answer_value: nil }
      let!(:condition_with_goto_page_missing) { create :condition, routing_page_id: pages.second.id, check_page_id: pages.second.id, goto_page_id: nil, answer_value: "Option 1" }

      before do
        pages.each(&:reload)

        render_inline(error_summary_component)
      end

      it "renders the error_summary" do
        expect(page).to have_css(".govuk-error-summary")
      end

      it "renders both error links" do
        condition_answer_value_error = I18n.t("errors.page_conditions.answer_value_doesnt_exist", question_number: 1, route_number: 1)
        condition_goto_page_error = I18n.t("errors.page_conditions.goto_page_doesnt_exist", question_number: 2, route_number: 1)
        expect(page).to have_link(condition_answer_value_error, href: "##{described_class.error_id(condition_with_answer_value_missing.id)}")
        expect(page).to have_link(condition_goto_page_error, href: "##{described_class.error_id(condition_with_goto_page_missing.id)}")
      end
    end

    context "when the form has a branch route" do
      let(:form) { create :form, :ready_for_routing }

      before do
        create :condition, routing_page_id: pages.first.id, check_page_id: pages.first.id, answer_value: "Option 1", goto_page_id: pages.last.id
        pages.each(&:reload)
      end

      context "and there is an error with the any other answer route" do
        let!(:secondary_skip_condition) { create :condition, routing_page_id: pages.second.id, check_page_id: pages.first.id, answer_value: nil, goto_page_id: pages.third.id }

        before do
          pages.each(&:reload)

          render_inline(error_summary_component)
        end

        it "renders the error summary" do
          error_message = I18n.t("errors.page_conditions.cannot_route_to_next_page", question_number: 1, route_number: "for any other answer")
          expect(page).to have_css ".govuk-error-summary", text: error_message
          expect(page).to have_link error_message, href: "#condition_#{secondary_skip_condition.id}"
        end
      end

      context "and the any other answer route skip to question has been moved to before the skip from question" do
        let!(:secondary_skip_condition) { create :condition, routing_page_id: pages.second.id, check_page_id: pages.first.id, answer_value: nil, goto_page_id: pages.first.id }

        before do
          pages.each(&:reload)

          render_inline(error_summary_component)
        end

        it "renders an error message" do
          error_message = I18n.t("errors.page_conditions.any_other_answer_route.cannot_have_goto_page_before_routing_page", question_number: 1, route_number: "for any other answer")
          expect(page).to have_css ".govuk-error-summary", text: error_message
          expect(page).to have_link error_message, href: "#condition_#{secondary_skip_condition.id}"
        end
      end
    end
  end

  describe "class methods" do
    let(:form) { create :form, :ready_for_routing }
    let!(:condition_with_answer_value_missing) { create :condition, routing_page_id: pages.first.id, check_page_id: pages.first.id, goto_page_id: pages.third.id, answer_value: nil }
    let!(:condition_with_goto_page_missing) { create :condition, routing_page_id: pages.second.id, check_page_id: pages.second.id, goto_page_id: nil, answer_value: "Option 1" }

    before do
      pages.each(&:reload)
    end

    describe "#error_id" do
      it "returns the correct id value" do
        expect(described_class.error_id(1)).to eq "condition_1"
      end
    end

    describe "#error_object" do
      it "returns an error object in the correct format" do
        expect(error_summary_component.error_object(error_name: "answer_value_doesnt_exist", condition: condition_with_answer_value_missing, page: pages.first)).to eq OpenStruct.new(message: I18n.t("errors.page_conditions.answer_value_doesnt_exist", question_number: pages.first.position, route_number: 1), link: "#condition_#{condition_with_answer_value_missing.id}")
      end
    end

    describe "#errors_for_summary" do
      it "returns all of the routing errors for a form with their respective positions and links" do
        expect(error_summary_component.errors_for_summary).to eq [
          OpenStruct.new(message: I18n.t("errors.page_conditions.answer_value_doesnt_exist", question_number: pages.first.position, route_number: 1), link: "#condition_#{condition_with_answer_value_missing.id}"),
          OpenStruct.new(message: I18n.t("errors.page_conditions.goto_page_doesnt_exist", question_number: pages.second.position, route_number: 1), link: "#condition_#{condition_with_goto_page_missing.id}"),
        ]
      end
    end
  end
end
