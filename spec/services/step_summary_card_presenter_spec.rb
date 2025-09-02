require "rails_helper"

describe StepSummaryCardPresenter do
  let(:page) { build :form_document_step, is_optional: }
  let(:is_optional) { false }
  let(:pages) do
    [page, *build_list(:form_document_step, 5)]
  end
  let(:presenter) { described_class.call(page:, pages:) }

  describe "#build_data" do
    before do
      allow(StepSummaryCardService).to receive(:call).and_return(OpenStruct.new(all_options_for_answer_type: [1, 2]))
    end

    it "includes a title" do
      expect(presenter.build_data[:card][:title]).to eq "1. #{page.question_text}"
    end

    it "includes an array of rows" do
      expect(presenter.build_data[:rows]).to eq [1, 2]
    end

    context "when the page is a selection question" do
      let(:page) { build :form_document_step, :with_selection_settings, is_optional: }

      it "includes a title without (optional) added to it" do
        expect(presenter.build_data[:card][:title]).to eq "1. #{page.question_text}"
      end
    end

    context "when question is optional" do
      let(:is_optional) { "true" }

      it "includes a title with (optional) added to it" do
        expect(presenter.build_data[:card][:title]).to eq "1. #{page.question_text} (optional)"
      end

      context "when the page is a selection question" do
        let(:page) { build :form_document_step, :with_selection_settings, is_optional: }

        it "includes a title without (optional) added to it" do
          expect(presenter.build_data[:card][:title]).to eq "1. #{page.question_text}"
        end
      end
    end

    context "when question is optional is nil" do
      let(:is_optional) { nil }

      it "includes a title" do
        expect(presenter.build_data[:card][:title]).to eq "1. #{page.question_text}"
      end

      context "when the page is a selection question" do
        let(:page) { build :form_document_step, :with_selection_settings, is_optional: }

        it "includes a title without (optional) added to it" do
          expect(presenter.build_data[:card][:title]).to eq "1. #{page.question_text}"
        end
      end
    end

    context "when file upload question contains guidance text" do
      let(:page) { build :form_document_step, :with_guidance, :with_file_upload_answer_type, is_optional: }

      it "includes the guidance text page heading as title" do
        expect(presenter.build_data[:card][:title]).to eq "1. #{page.page_heading}"
      end

      context "when the question is optional" do
        let(:is_optional) { "true" }

        it "includes a title with (optional) added to it" do
          expect(presenter.build_data[:card][:title]).to eq "1. #{page.page_heading} (optional)"
        end
      end
    end
  end
end
