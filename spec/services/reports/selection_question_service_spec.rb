require "rails_helper"

RSpec.describe Reports::SelectionQuestionService do
  subject(:selection_question_service) { described_class.new(form_documents) }

  describe "#statistics" do
    let(:form_documents) do
      form_1_pages = [
        build(:page, :selection_with_autocomplete, is_optional: false),
        build(:page, :selection_with_autocomplete, is_optional: true),
        build(:page, :selection_with_radios, is_optional: true),
        build(:page, :selection_with_checkboxes, is_optional: true),
      ]
      form_2_pages = [
        build(:page, :selection_with_autocomplete, is_optional: true),
        build(:page, :selection_with_radios, is_optional: false),
      ]

      [
        create(:form, :live, pages: form_1_pages).live_form_document.as_json,
        create(:form, :live, pages: form_2_pages).live_form_document.as_json,
      ]
    end

    it "returns statistics" do
      response = selection_question_service.statistics
      expect(response[:autocomplete][:form_ids].length).to be 2
      expect(response[:autocomplete][:question_count]).to be 3
      expect(response[:autocomplete][:optional_question_count]).to be 2
      expect(response[:radios][:form_ids].length).to be 2
      expect(response[:radios][:question_count]).to be 2
      expect(response[:radios][:optional_question_count]).to be 1
      expect(response[:checkboxes][:form_ids].length).to be 1
      expect(response[:checkboxes][:optional_question_count]).to be 1
    end
  end
end
