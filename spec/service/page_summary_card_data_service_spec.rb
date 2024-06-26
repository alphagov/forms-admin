require "rails_helper"

describe PageSummaryCardDataService do
  let(:page) { build :page, is_optional: }
  let(:is_optional) { false }
  let(:pages) do
    form = build :form, :with_pages
    form.pages
  end
  let(:service) { described_class.call(page:, pages:) }

  describe "#build_data" do
    before do
      allow(PageOptionsService).to receive(:call).and_return(OpenStruct.new(all_options_for_answer_type: [1, 2]))
    end

    it "includes a title" do
      expect(service.build_data[:card][:title]).to eq page.question_text
    end

    it "includes an array of rows" do
      expect(service.build_data[:rows]).to eq [1, 2]
    end

    context "when the page is a selection question" do
      let(:page) { build :page, :with_selections_settings, is_optional: }

      it "includes a title without (optional) added to it" do
        expect(service.build_data[:card][:title]).to eq page.question_text.to_s
      end
    end

    context "when question is optional" do
      let(:is_optional) { "true" }

      it "includes a title with (optional) added to it" do
        expect(service.build_data[:card][:title]).to eq "#{page.question_text} (optional)"
      end

      context "when the page is a selection question" do
        let(:page) { build :page, :with_selections_settings, is_optional: }

        it "includes a title without (optional) added to it" do
          expect(service.build_data[:card][:title]).to eq page.question_text.to_s
        end
      end
    end

    context "when question is optional is nil" do
      let(:is_optional) { nil }

      it "includes a title" do
        expect(service.build_data[:card][:title]).to eq page.question_text
      end

      context "when the page is a selection question" do
        let(:page) { build :page, :with_selections_settings, is_optional: }

        it "includes a title without (optional) added to it" do
          expect(service.build_data[:card][:title]).to eq page.question_text.to_s
        end
      end
    end
  end
end
