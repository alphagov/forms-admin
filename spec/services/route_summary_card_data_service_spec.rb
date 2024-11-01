require "rails_helper"

describe RouteSummaryCardDataService do
  subject(:service) { described_class.new(page: current_page, pages:) }

  let(:current_page) do
    build(:page, id: 1, position: 1, question_text: "Current Question", next_page: next_page.id, routing_conditions: [routing_condition])
  end

  let(:next_page) do
    build(:page, id: 2, position: 2, question_text: "Next Question")
  end

  let(:pages) { [current_page, next_page] }

  let(:routing_condition) do
    build(:condition, routing_page_id: 1, check_page_id: 1, answer_value: "Yes", goto_page_id: 2, skip_to_end: false)
  end

  describe ".call" do
    it "instantiates and returns a new instance" do
      service = described_class.call(page: current_page, pages:)
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
        expect(result[0][:rows][0][:value][:text]).to eq("Yes")
        expect(result[0][:rows][1][:value][:text]).to eq("2. Next Question")

        # default route
        expect(result[1][:card][:title]).to eq("For any other answer")
        expect(result[1][:rows][0][:value][:text]).to eq("2. Next Question")
      end
    end

    context "with skip to end condition" do
      let(:routing_condition) do
        build(:condition, routing_page_id: 1, check_page_id: 1, answer_value: "No", goto_page_id: nil, skip_to_end: true)
      end

      it 'shows "Check your answers" as destination' do
        result = service.summary_card_data
        expect(result[0][:rows][1][:value][:text]).to eq("Check your answers before submitting")
      end
    end

    context "with no conditional routes" do
      let(:routing_condition) { nil }

      it "returns only the default route card" do
        result = service.summary_card_data
        expect(result.length).to eq(1)
        expect(result[0][:card][:title]).to eq("For any other answer")
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
  end
end
