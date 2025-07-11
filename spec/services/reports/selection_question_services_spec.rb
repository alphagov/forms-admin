require "rails_helper"

RSpec.describe Reports::SelectionQuestionService do
  subject(:selection_question_service) { described_class.new }

  describe "#live_form_statistics" do
    before do
      form_1_pages = [
        build(:page_record, :selection_with_autocomplete, is_optional: false),
        build(:page_record, :selection_with_autocomplete, is_optional: true),
        build(:page_record, :selection_with_radios, is_optional: true),
        build(:page_record, :selection_with_checkboxes, is_optional: true),
      ]
      form_2_pages = [
        build(:page_record, :selection_with_autocomplete, is_optional: true),
        build(:page_record, :selection_with_radios, is_optional: false),
      ]
      create :form_record, state: "live", pages: form_1_pages
      create :form_record, state: "live_with_draft", pages: form_2_pages
    end

    it "returns statistics" do
      response = selection_question_service.live_form_statistics
      expect(response[:autocomplete].unique_form_ids_set.length).to be 2
      expect(response[:autocomplete].question_count).to be 3
      expect(response[:autocomplete].optional_question_count).to be 2
      expect(response[:radios].unique_form_ids_set.length).to be 2
      expect(response[:radios].question_count).to be 2
      expect(response[:radios].optional_question_count).to be 1
      expect(response[:checkboxes].unique_form_ids_set.length).to be 1
      expect(response[:checkboxes].optional_question_count).to be 1
    end
  end

  describe "list question methods" do
    let(:form) { create :form_record, state: "live", pages: [page_with_checkboxes, page_with_radios, page_with_autocomplete] }
    let(:page_with_autocomplete) { build(:page_record, :selection_with_autocomplete) }
    let(:page_with_radios) { build(:page_record, :selection_with_radios) }
    let(:page_with_checkboxes) { build(:page_record, :selection_with_checkboxes) }
    let(:not_selection_question) { build :page_record, answer_type: "name" }

    before do
      form
    end

    describe "#live_form_pages_with_autocomplete" do
      it "returns question with autocomplete" do
        response = selection_question_service.live_form_pages_with_autocomplete
        questions = response[:questions]
        expect(questions.length).to be(1)
        expect(questions.first[:form_id]).to eq(form.id)
        expect(questions.first[:form_name]).to eq(form.name)
        expect(questions.first[:question_text]).to eq(page_with_autocomplete.question_text)
        expect(questions.first[:is_optional]).to eq(page_with_autocomplete.is_optional)
        expect(questions.first[:selection_options_count]).to eq(31)
      end

      it "returns the count" do
        response = selection_question_service.live_form_pages_with_radios
        expect(response[:count]).to eq(1)
      end
    end

    describe "#live_form_pages_with_radios" do
      it "returns question with radios" do
        response = selection_question_service.live_form_pages_with_radios
        questions = response[:questions]
        expect(questions.length).to be(1)
        expect(questions.first[:form_id]).to eq(form.id)
        expect(questions.first[:form_name]).to eq(form.name)
        expect(questions.first[:question_text]).to eq(page_with_radios.question_text)
        expect(questions.first[:is_optional]).to eq(page_with_radios.is_optional)
        expect(questions.first[:selection_options_count]).to eq(30)
      end

      it "returns the count" do
        response = selection_question_service.live_form_pages_with_radios
        expect(response[:count]).to eq(1)
      end
    end

    describe "#live_form_pages_with_checkboxes" do
      it "returns question with checkboxes" do
        response = selection_question_service.live_form_pages_with_checkboxes
        questions = response[:questions]
        expect(questions.length).to be(1)
        expect(questions.first[:form_id]).to eq(form.id)
        expect(questions.first[:form_name]).to eq(form.name)
        expect(questions.first[:question_text]).to eq(page_with_checkboxes.question_text)
        expect(questions.first[:is_optional]).to eq(page_with_checkboxes.is_optional)
        expect(questions.first[:selection_options_count]).to eq(2)
      end

      it "returns the count" do
        response = selection_question_service.live_form_pages_with_radios
        expect(response[:count]).to eq(1)
      end

      # This ensures there is backwards compatibility for existing questions as we previously set "only_one_option" to
      # "0" rather than "false"
      context "when question has only_one_option value '0'" do
        let(:page_with_checkboxes) do
          create(:page_record,
                 answer_type: "selection",
                 answer_settings: {
                   only_one_option: "0",
                   selection_options: [{ name: "Option 1" }, { name: "Option 2" }],
                 })
        end

        it "returns question with checkboxes" do
          response = selection_question_service.live_form_pages_with_checkboxes
          questions = response[:questions]
          expect(questions.length).to be(1)
          expect(questions.first[:question_text]).to eq(page_with_checkboxes.question_text)
        end
      end
    end
  end
end
