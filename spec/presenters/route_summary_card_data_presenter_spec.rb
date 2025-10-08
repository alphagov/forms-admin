require "rails_helper"

describe RouteSummaryCardDataPresenter do
  include Capybara::RSpecMatchers

  subject(:service) { described_class.new(form:, page:) }

  let(:form) { create :form, :ready_for_routing }
  let(:pages) { form.pages }
  let(:page) { pages.first }

  before do
    allow(form).to receive(:group).and_return(build(:group))
  end

  describe "#summary_card_data" do
    context "with conditional routes" do
      before do
        pages.each(&:reload)
      end

      context "when there is a valid condition" do
        let!(:condition) { create :condition, routing_page_id: page.id, check_page_id: page.id, goto_page_id: pages.last.id, answer_value: "Option 1" }

        it "returns an array of route cards" do
          result = service.summary_card_data
          expect(result.length).to eq(1) # 1 conditional route

          # conditional route
          expect(result[0][:card][:title]).to eq("Route 1")
          expect(result[0][:card][:actions].first).to have_link("Edit", href: "/forms/#{form.id}/pages/#{page.id}/conditions/#{condition.id}")
          expect(result[0][:rows][0][:value][:text]).to eq("Option 1")
          expect(result[0][:rows][1][:value][:text]).to eq("#{pages.last.position}. #{pages.last.question_text}")
        end
      end

      context "when the goto_page does not exist" do
        before do
          create :condition, routing_page_id: page.id, check_page_id: page.id, goto_page_id: 127, answer_value: "Option 1"
        end

        it "uses placeholder text instead of question text" do
          result = service.summary_card_data
          expect(result[0][:rows][1][:value][:text]).to eq(I18n.t("page_route_card.goto_page_invalid"))
        end
      end
    end

    context "when the condition has an exit page data" do
      let!(:condition) { create :condition, :with_exit_page, routing_page_id: page.id, check_page_id: page.id, answer_value: "Option 1" }

      before do
        pages.each(&:reload)
      end

      it "uses the exit page heading in the summary card" do
        result = service.summary_card_data
        expect(result[0][:rows][1][:value][:text]).to eq(condition.exit_page_heading)
      end
    end

    context "with skip to end condition" do
      before do
        create :condition, routing_page_id: page.id, check_page_id: page.id, answer_value: "Option 1", skip_to_end: true
        pages.each(&:reload)
      end

      it 'shows "Check your answers" as destination' do
        result = service.summary_card_data
        expect(result[0][:rows][1][:value][:text]).to eq("Check your answers before submitting")
      end
    end

    context "with conditional routes and secondary skip routes" do
      let(:condition) { create :condition, routing_page_id: page.id, check_page_id: page.id, goto_page_id: pages.fourth.id, answer_value: "Option 1" }
      let(:secondary_skip_condition) { create :condition, routing_page_id: pages.third.id, check_page_id: page.id, goto_page_id: pages.last.id }

      before do
        condition
        secondary_skip_condition
        pages.each(&:reload)
      end

      it "shows the destination of the secondary skip route" do
        result = service.summary_card_data
        expect(result[1][:rows][0][:value][:text]).to eq("#{pages.second.position}. #{pages.second.question_text}")
        expect(result[1][:rows][1][:value][:text]).to eq("#{pages.third.position}. #{pages.third.question_text}")
        expect(result[1][:rows][2][:value][:text]).to eq("#{pages.last.position}. #{pages.last.question_text}")
      end

      it "shows the edit secondary skip link" do
        result = service.summary_card_data
        expect(result[1][:card][:actions].first).to have_link("Edit", href: "/forms/#{form.id}/pages/#{page.id}/routes/any-other-answer/questions-to-skip")
      end

      it "shows the delete secondary skip link" do
        result = service.summary_card_data
        expect(result[1][:card][:actions].second).to have_link("Delete", href: "/forms/#{form.id}/pages/#{page.id}/routes/any-other-answer/questions-to-skip/delete")
      end

      context "when the route's check answer does not exist" do
        let(:condition) { create :condition, routing_page_id: page.id, check_page_id: page.id, goto_page_id: pages.fourth.id, answer_value: "Non-existent-option" }

        it "shows an error message" do
          result = service.summary_card_data
          expect(result[0][:rows][0][:value][:text]).to include("The answer that route 1 is based on no longer exists - edit or delete this route")
          expect(result[0][:rows][0][:value][:text]).to include("class=\"govuk-summary-list__value--error\"")
        end
      end

      context "when route 1 does not skip any questions" do
        let(:condition) { create :condition, routing_page_id: page.id, check_page_id: page.id, goto_page_id: pages.second.id, answer_value: "Option 1" }

        it "shows an error message" do
          result = service.summary_card_data
          expect(result[0][:rows][1][:value][:text]).to include("Route 1 is not skipping any questions - edit or delete this route")
          expect(result[0][:rows][1][:value][:text]).to include("class=\"govuk-summary-list__value--error\"")
        end
      end

      context "when route 1 routes to a previous question" do
        let(:page) { pages.second }
        let(:condition) { create :condition, routing_page_id: page.id, check_page_id: page.id, goto_page_id: pages.first.id, answer_value: "Option 1" }

        it "shows an error message" do
          result = service.summary_card_data
          expect(result[0][:rows][1][:value][:text]).to include("The question route 1 skips to cannot be before question 2 - edit or delete this route")
          expect(result[0][:rows][1][:value][:text]).to include("class=\"govuk-summary-list__value--error\"")
        end
      end

      context "when the any other answer route does not skip a question" do
        let(:secondary_skip_condition) { create :condition, routing_page_id: pages.third.id, check_page_id: page.id, goto_page_id: pages.fourth.id }

        it "shows an error message" do
          result = service.summary_card_data
          expect(result[1][:rows][2][:value][:text]).to include("The route for any other answer is not skipping any questions - edit or delete this route")
          expect(result[1][:rows][2][:value][:text]).to include("class=\"govuk-summary-list__value--error\"")
        end
      end

      context "when the any other answer route skips to a previous question" do
        let(:secondary_skip_condition) { create :condition, routing_page_id: pages.third.id, check_page_id: page.id, goto_page_id: pages.second.id }

        it "shows an error message" do
          result = service.summary_card_data
          expect(result[1][:rows][2][:value][:text]).to include("The question the route for any other answer skips to cannot be before the question it skips from - edit or delete this route")
          expect(result[1][:rows][2][:value][:text]).to include("class=\"govuk-summary-list__value--error\"")
        end
      end
    end

    context "with no conditional routes" do
      it "returns an empty array" do
        result = service.summary_card_data
        expect(result).to eq []
      end
    end
  end

  describe "#routes" do
    let!(:condition) { create :condition, routing_page: page, check_page: page, goto_page: pages.third, answer_value: "Option 1" }
    let!(:secondary_skip_condition) { create :condition, routing_page: pages.second, check_page: page, goto_page: pages.fourth }

    before do
      pages.each(&:reload)
    end

    it "returns the conditions that check this page" do
      expect(service.routes.count).to eq 2
      expect(service.routes).to contain_exactly(condition, secondary_skip_condition)
    end
  end

  describe "#next_page" do
    it "returns the next page" do
      expect(service.next_page).to eq(pages.second)
    end
  end

  describe "#errors" do
    let(:condition) { create :condition, routing_page_id: page.id, check_page_id: page.id, goto_page_id: pages.fourth.id, answer_value: "Option 1" }
    let(:secondary_skip_condition) { create :condition, routing_page_id: pages.third.id, check_page_id: page.id, goto_page_id: pages.last.id }

    before do
      condition
      secondary_skip_condition
      pages.each(&:reload)
    end

    it "returns an array of errors" do
      expect(service.errors).to be_empty
    end

    context "when there is a check error" do
      let(:condition) { create :condition, routing_page_id: page.id, check_page_id: page.id, goto_page_id: pages.fourth.id, answer_value: "Non-existent-answer" }

      it "contains the check error link and message" do
        expect(service.errors).to eq([OpenStruct.new(link: "#check-#{condition.id}", message: I18n.t("page_route_card.errors.answer_value_doesnt_exist"))])
      end
    end

    context "when there is a next page error" do
      let(:condition) { create :condition, routing_page_id: page.id, check_page_id: page.id, goto_page_id: pages.second.id, answer_value: "Option 1" }

      it "contains the next page error link and message" do
        expect(service.errors).to eq([OpenStruct.new(link: "#goto-#{condition.id}", message: I18n.t("page_route_card.errors.cannot_route_to_next_page"))])
      end
    end

    context "when there is a next page error for the secondary skip" do
      let(:secondary_skip_condition) { create :condition, routing_page_id: pages.third.id, check_page_id: page.id, goto_page_id: pages.fourth.id }

      it "contains the secondary skip next page error link and message" do
        expect(service.errors).to eq([OpenStruct.new(link: "#goto-#{secondary_skip_condition.id}", message: I18n.t("page_route_card.errors.cannot_route_to_next_page_secondary_skip"))])
      end
    end

    context "when there is a goto page before routing page error" do
      let(:page) { pages.second }
      let(:condition) { create :condition, routing_page_id: page.id, check_page_id: page.id, goto_page_id: pages.first.id, answer_value: "Option 1" }

      it "contains the goto page before routing page error link and message" do
        expect(service.errors).to eq([OpenStruct.new(link: "#goto-#{condition.id}", message: I18n.t("page_route_card.errors.cannot_have_goto_page_before_routing_page", question_number: 2))])
      end
    end

    context "when there is a goto page before routing page error for the secondary skip" do
      let(:secondary_skip_condition) { create :condition, routing_page_id: pages.third.id, check_page_id: page.id, goto_page_id: pages.second.id }

      it "contains the secondary skip goto page before routing page error link and message" do
        expect(service.errors).to eq([OpenStruct.new(link: "#goto-#{secondary_skip_condition.id}", message: I18n.t("page_route_card.errors.cannot_have_goto_page_before_routing_page_secondary_skip"))])
      end
    end
  end
end
