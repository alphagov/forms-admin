require "rails_helper"

describe PageSummaryCardDataService do
  let(:page) { build :page, is_optional: optional }
  let(:optional) { false }
  let(:service) { described_class.call(page:) }

  describe "#build_data" do
    before do
      allow(PageOptionsService).to receive(:call).and_return(OpenStruct.new(all_options_for_answer_type: [1, 2]))
    end

    it "includes a title" do
      expect(service.build_data[:title]).to eq page.question_text
    end

    it "includes an array of rows " do
      expect(service.build_data[:rows]).to eq [1, 2]
    end

    context "when question is optional" do
      let(:optional) { "true" }

      it "includes a title with (optional) added to it" do
        expect(service.build_data[:title]).to eq "#{page.question_text} (optional)"
      end
    end

    context "when question is optional is nil" do
      let(:optional) { nil }

      it "includes a title" do
        expect(service.build_data[:title]).to eq page.question_text
      end
    end
  end
end
