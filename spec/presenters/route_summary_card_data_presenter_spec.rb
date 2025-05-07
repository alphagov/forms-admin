require "rails_helper"

describe RouteSummaryCardDataPresenter do
  include Capybara::RSpecMatchers

  subject(:service) { described_class.new(form:, page:) }

  include_context "with pages with routing"

  let(:form) { build :form, id: 99, pages: }
  let(:page) { page_with_skip_route }

  let(:routes) do
    PageRoutesService.new(form:, pages:, page:).routes
  end

  before do
    allow(form).to receive(:group).and_return(build(:group))
  end

  describe "#summary_card_data" do
    context "with conditional routes" do
      it "returns an array of route cards" do
        result = service.summary_card_data
        expect(result.length).to eq(1) # 1 conditional route

        # conditional route
        expect(result[0][:card][:title]).to eq("Route 1")
        expect(result[0][:card][:actions].first).to have_link("Edit", href: "/forms/99/pages/10/conditions/3")
        expect(result[0][:rows][0][:value][:text]).to eq("Skip")
        expect(result[0][:rows][1][:value][:text]).to eq("12. Question")
      end

      context "when the goto_page does not exist" do
        before do
          page.routing_conditions.first.tap do |condition|
            condition.goto_page_id = 999
          end
        end

        it "uses placeholder text instead of question text" do
          result = service.summary_card_data
          expect(result[0][:rows][1][:value][:text]).to eq(I18n.t("page_route_card.goto_page_invalid"))
        end
      end
    end

    context "when the condition has an exit page data" do
      before do
        page.routing_conditions.first.tap do |condition|
          condition.exit_page_heading = "Exit page"
          condition.exit_page_markdown = "This is the exit page"
        end
      end

      it "uses the exit page heading in the summary card" do
        result = service.summary_card_data
        expect(result[0][:rows][1][:value][:text]).to eq("Exit page")
      end
    end

    context "with skip to end condition" do
      before do
        page.routing_conditions.first.tap do |condition|
          condition.goto_page_id = nil
          condition.skip_to_end = true
        end
      end

      it 'shows "Check your answers" as destination' do
        result = service.summary_card_data
        expect(result[0][:rows][1][:value][:text]).to eq("Check your answers before submitting")
      end
    end

    context "with conditional routes and secondary skip routes" do
      let(:page) { page_with_skip_and_secondary_skip }

      it "shows the destination of the secondary skip route" do
        result = service.summary_card_data
        expect(result[1][:rows][0][:value][:text]).to eq("3. Question in branch 1")
        expect(result[1][:rows][1][:value][:text]).to eq("4. Question at the end of branch 1 (start of a secondary skip)")
        expect(result[1][:rows][2][:value][:text]).to eq("8. Question after a branch route (end of a secondary skip)")
      end

      context "when branch routing is not enabled", feature_branch_routing: false do
        it "has no actions" do
          result = service.summary_card_data
          expect(result[1][:card][:actions]).to be_empty
        end
      end

      context "with branch_routing enabled", :feature_branch_routing do
        it "shows the edit secondary skip link" do
          result = service.summary_card_data
          expect(result[1][:card][:actions].first).to have_link("Edit", href: "/forms/99/pages/2/routes/any-other-answer/questions-to-skip")
        end

        it "shows the delete secondary skip link" do
          result = service.summary_card_data
          expect(result[1][:card][:actions].second).to have_link("Delete", href: "/forms/99/pages/2/routes/any-other-answer/questions-to-skip/delete")
        end
      end

      context "when the route's check answer does not exist" do
        it "shows an error message" do
          branch_route_1.validation_errors << OpenStruct.new(name: "answer_value_doesnt_exist")

          result = service.summary_card_data
          expect(result[0][:rows][0][:value][:text]).to include("The answer that route 1 is based on no longer exists - edit or delete this route")
          expect(result[0][:rows][0][:value][:text]).to include("class=\"govuk-summary-list__value--error\"")
        end
      end

      context "when route 1 does not skip any questions" do
        it "shows an error message" do
          branch_route_1.validation_errors << OpenStruct.new(name: "cannot_route_to_next_page")

          result = service.summary_card_data
          expect(result[0][:rows][1][:value][:text]).to include("Route 1 is not skipping any questions - edit or delete this route")
          expect(result[0][:rows][1][:value][:text]).to include("class=\"govuk-summary-list__value--error\"")
        end
      end

      context "when route 1 routes to a previous question" do
        it "shows an error message" do
          branch_route_1.validation_errors << OpenStruct.new(name: "cannot_have_goto_page_before_routing_page")

          result = service.summary_card_data
          expect(result[0][:rows][1][:value][:text]).to include("The question route 1 skips to cannot be before question 2 - edit or delete this route")
          expect(result[0][:rows][1][:value][:text]).to include("class=\"govuk-summary-list__value--error\"")
        end
      end

      context "when the any other answer route does not skip a question" do
        it "shows an error message" do
          branch_any_other_answer_route.validation_errors << OpenStruct.new(name: "cannot_route_to_next_page")

          result = service.summary_card_data
          expect(result[1][:rows][2][:value][:text]).to include("The route for any other answer is not skipping any questions - edit or delete this route")
          expect(result[1][:rows][2][:value][:text]).to include("class=\"govuk-summary-list__value--error\"")
        end
      end

      context "when the any other answer route skips to a previous question" do
        it "shows an error message" do
          branch_any_other_answer_route.validation_errors << OpenStruct.new(name: "cannot_have_goto_page_before_routing_page")

          result = service.summary_card_data
          expect(result[1][:rows][2][:value][:text]).to include("The question the route for any other answer skips to cannot be before the question it skips from - edit or delete this route")
          expect(result[1][:rows][2][:value][:text]).to include("class=\"govuk-summary-list__value--error\"")
        end
      end
    end

    context "with no conditional routes" do
      let(:page) { page_with_no_routes }

      it "returns an empty array" do
        result = service.summary_card_data
        expect(result).to eq []
      end
    end
  end

  describe "#routes" do
    it "calls the PageRoutesService" do
      double = instance_double(PageRoutesService, routes: [])
      allow(PageRoutesService).to receive(:new).with(form: form, pages: pages, page: page).and_return(double)
      service.routes
      expect(double).to have_received(:routes)
    end
  end

  describe "#pages" do
    it "calls the FormRepository" do
      expect(FormRepository).to receive(:pages).with(form)
      service.pages
    end
  end

  describe "#next_page" do
    it "returns the next page" do
      allow(FormRepository).to receive(:pages).and_return(pages)
      expect(service.next_page).to eq(pages[10])
    end
  end

  describe "#errors" do
    let(:page) { page_with_skip_and_secondary_skip }

    it "returns an array of errors" do
      expect(service.errors).to be_empty
    end

    context "when there is a check error" do
      it "contains the check error link and message" do
        branch_route_1.validation_errors << OpenStruct.new(name: "answer_value_doesnt_exist")
        expect(service.errors).to eq([OpenStruct.new(link: "#check-#{branch_route_1.id}", message: I18n.t("page_route_card.errors.answer_value_doesnt_exist"))])
      end
    end

    context "when there is a next page error" do
      it "contains the next page error link and message" do
        branch_route_1.validation_errors << OpenStruct.new(name: "cannot_route_to_next_page")
        expect(service.errors).to eq([OpenStruct.new(link: "#goto-#{branch_route_1.id}", message: I18n.t("page_route_card.errors.cannot_route_to_next_page"))])
      end
    end

    context "when there is a next page error for the secondary skip" do
      it "contains the secondary skip next page error link and message" do
        branch_any_other_answer_route.validation_errors << OpenStruct.new(name: "cannot_route_to_next_page")
        expect(service.errors).to eq([OpenStruct.new(link: "#goto-#{branch_any_other_answer_route.id}", message: I18n.t("page_route_card.errors.cannot_route_to_next_page_secondary_skip"))])
      end
    end

    context "when there is a goto page before routing page error" do
      it "contains the goto page before routing page error link and message" do
        branch_route_1.validation_errors << OpenStruct.new(name: "cannot_have_goto_page_before_routing_page")
        expect(service.errors).to eq([OpenStruct.new(link: "#goto-#{branch_route_1.id}", message: I18n.t("page_route_card.errors.cannot_have_goto_page_before_routing_page", question_number: 2))])
      end
    end

    context "when there is a goto page before routing page error for the secondary skip" do
      it "contains the secondary skip goto page before routing page error link and message" do
        branch_any_other_answer_route.validation_errors << OpenStruct.new(name: "cannot_have_goto_page_before_routing_page")
        expect(service.errors).to eq([OpenStruct.new(link: "#goto-#{branch_any_other_answer_route.id}", message: I18n.t("page_route_card.errors.cannot_have_goto_page_before_routing_page_secondary_skip"))])
      end
    end
  end
end
