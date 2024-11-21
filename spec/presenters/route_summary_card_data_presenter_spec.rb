require "rails_helper"

describe RouteSummaryCardDataPresenter do
  include Capybara::RSpecMatchers

  subject(:service) { described_class.new(form:, page: current_page, pages:) }

  let(:form) { build :form, id: 99, pages: }

  let(:current_page) do
    build(:page, id: 1, position: 1, question_text: "Current Question", next_page: next_page.id, routing_conditions:)
  end

  let(:next_page) do
    build(:page, id: 2, position: 2, question_text: "Next Question", routing_conditions: next_page_routing_conditions)
  end

  let(:pages) { [current_page, next_page] }

  let(:routing_condition) do
    build(:condition, id: 1, routing_page_id: 1, check_page_id: 1, answer_value: "Yes", goto_page_id: 2, skip_to_end: false)
  end

  let(:routing_conditions) { [routing_condition] }

  let(:next_page_routing_conditions) { [] }

  describe ".call" do
    it "instantiates and returns a new instance" do
      service = described_class.call(form:, page: current_page, pages:)
      expect(service).to be_an_instance_of(described_class)
    end
  end

  describe "#summary_card_data" do
    context "with conditional routes" do
      it "returns an array of route cards including conditional and default routes" do
        result = service.summary_card_data
        expect(result.length).to eq(2) # 1 conditional + 1 default route

        # conditional route
        expect(result[0][:card][:title]).to eq("Route 1")
        expect(result[0][:card][:actions].first).to have_link("Edit", href: "/forms/99/pages/1/conditions/1")
        expect(result[0][:rows][0][:value][:text]).to eq("Yes")
        expect(result[0][:rows][1][:value][:text]).to eq("2. Next Question")

        # default route
        expect(result[1][:card][:title]).to eq("Route 2")
        expect(result[1][:card][:actions][0]).to be_nil
        expect(result[1][:rows][0][:value][:text]).to eq("2. Next Question")
      end

      context "with branch_routing enabled", :feature_branch_routing do
        it "has the link to create a secondary skip" do
          result = service.summary_card_data
          expect(result[1][:rows][1][:value][:text]).to have_link("Set one or more questions to skip later in the form (optional)", href: "/forms/99/pages/1/routes/any-other-answer/questions-to-skip/new")
        end
      end
    end

    context "with skip to end condition" do
      let(:routing_condition) do
        build(:condition, id: 1, routing_page_id: 1, check_page_id: 1, answer_value: "No", goto_page_id: nil, skip_to_end: true)
      end

      it 'shows "Check your answers" as destination' do
        result = service.summary_card_data
        expect(result[0][:rows][1][:value][:text]).to eq("Check your answers before submitting")
      end
    end

    context "with a route with no answer_value" do
      let(:routing_conditions) do
        [build(:condition, id: 1, routing_page_id: 1, check_page_id: 1, answer_value: "Yes", goto_page_id: 2, skip_to_end: false)]
      end

      let(:next_page_routing_conditions) do
        [
          build(:condition, id: 2, routing_page_id: 2, check_page_id: 1, answer_value: nil, goto_page_id: nil, skip_to_end: true),
        ]
      end

      it 'shows "Check your answers" as destination' do
        result = service.summary_card_data
        expect(result[1][:rows][0][:value][:text]).to eq("2. Next Question")
        expect(result[1][:rows][1][:value][:text]).to eq("2. Next Question")
        expect(result[1][:rows][2][:value][:text]).to eq("Check your answers before submitting")
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
          expect(result[1][:card][:actions].first).to have_link("Edit", href: "/forms/99/pages/1/routes/any-other-answer/questions-to-skip")
        end

        it "shows the delete secondary skip link" do
          result = service.summary_card_data
          expect(result[1][:card][:actions].second).to have_link("Delete", href: "#")
        end
      end
    end

    context "with no conditional routes" do
      let(:routing_conditions) { [] }

      it "returns only the default route card" do
        result = service.summary_card_data
        expect(result.length).to eq(1)
        expect(result[0][:card][:title]).to eq("Route 1")
      end
    end

    context "when page is the last page" do
      let(:current_page) do
        build(:page, id: 1, position: 1, question_text: "Current Question", next_page: nil)
      end

      it 'shows "Check your answers" as default destination' do
        result = service.summary_card_data
        expect(result[0][:rows][0][:value][:text]).to eq("Check your answers before submitting")
      end
    end

    describe "#all_routes" do
      context "when no pages have conditions" do
        let(:routing_conditions) { [] }

        it "is an empty array when there are no matching conditions" do
          expect(service.all_routes).to be_empty
        end
      end

      context "when pages have conditions with matching check_page_ids" do
        let(:pages) do
          [
            build(:page, id: 1, position: 1, question_text: "Current Question", next_page: next_page.id, routing_conditions: [
              build(:condition, id: 1, routing_page_id: 1, check_page_id: 1, answer_value: "Yes", goto_page_id: 2, skip_to_end: false),
            ]),
            build(:page, id: 2, position: 2, question_text: "Next Question", routing_conditions: [
              build(:condition, id: 1, routing_page_id: 2, check_page_id: 1, answer_value: nil, goto_page_id: nil, skip_to_end: true),
            ]),
            build(:page, id: 3, position: 3, question_text: "unrelated question", routing_conditions: [
              build(:condition, id: 1, routing_page_id: 3, check_page_id: 3, answer_value: "Unrelated", goto_page_id: 5, skip_to_end: false),
            ]),
          ]
        end

        it "returns all condtions which match the check_page_id" do
          expected_condtions = pages.first.routing_conditions + pages.second.routing_conditions
          expect(service.all_routes).to match_array(expected_condtions)
        end
      end
    end
  end
end
