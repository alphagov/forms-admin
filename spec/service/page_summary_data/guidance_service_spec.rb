require "rails_helper"

RSpec.describe PageSummaryData::GuidanceService do
  include Rails.application.routes.url_helpers

  let(:service) { described_class.call(form:, page: draft_question) }
  let(:form) { build :form, id: 1 }
  let(:draft_question) { build :draft_question, :with_guidance, page_id:, form_id: form.id }
  let(:page_id) { nil }

  describe "#build_data" do
    let(:result) { service.build_data }

    it "returns an array of rows" do
      expect(result[:rows].size).to eq 2
    end

    describe "first row of summary list" do
      let(:row) { result[:rows].first }

      it "has key" do
        expect(row[:key][:text]).to eq "Page heading"
      end

      it "has a value" do
        expect(row[:value][:text]).to eq draft_question.page_heading
      end

      it "has an action to take the user back to change the value" do
        expect(row[:actions].first[:href]).to eq(guidance_new_path(form_id: form.id))
      end

      context "when editing guidance for an existing page" do
        let(:page_id) { 1 }

        it "has an action to take the user back to change the value" do
          expect(row[:actions].first[:href]).to eq(guidance_edit_path(form_id: form.id, page_id:))
        end
      end
    end

    describe "second row of summary list" do
      let(:row) { result[:rows].second }

      it "has key" do
        expect(row[:key][:text]).to eq "Guidance text"
      end

      it "has a value" do
        expect(row[:value][:text]).to eq("<pre class=\"app-markdown-editor__markdown-example-block\">#{draft_question.guidance_markdown}</pre>")
      end

      it "has an action to take the user back to change the value" do
        expect(row[:actions].first[:href]).to eq(guidance_new_path(form_id: form.id))
      end

      context "when editing guidance for an existing page" do
        let(:page_id) { 1 }

        it "has an action to take the user back to change the value" do
          expect(row[:actions].first[:href]).to eq(guidance_edit_path(form_id: form.id, page_id:))
        end
      end
    end

    context "when draft question doesn't have guidance or page heading" do
      let(:draft_question) { build :draft_question, form_id: form.id }

      it "returns nil" do
        expect(result).to be_nil
      end
    end
  end
end
