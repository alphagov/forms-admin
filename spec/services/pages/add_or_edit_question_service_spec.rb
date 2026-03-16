require "rails_helper"

RSpec.describe Pages::AddOrEditQuestionService do
  include Rails.application.routes.url_helpers

  let(:form_id) { 123 }

  describe "#new_or_edit_path_for_answer_type" do
    context "when creating a new page (no existing_page_id)" do
      subject(:service) { described_class.new(form_id: form_id, existing_page_id: nil) }

      it "returns question text path for selection questions" do
        expect(service.new_or_edit_path_for_answer_type("selection")).to eq(question_text_new_path(form_id))
      end

      it "returns text settings new path for text questions" do
        expect(service.new_or_edit_path_for_answer_type("text")).to eq(text_settings_new_path(form_id))
      end

      it "returns date settings new path for date questions" do
        expect(service.new_or_edit_path_for_answer_type("date")).to eq(date_settings_new_path(form_id))
      end

      it "returns address settings new path for address questions" do
        expect(service.new_or_edit_path_for_answer_type("address")).to eq(address_settings_new_path(form_id))
      end

      it "returns name settings new path for name questions" do
        expect(service.new_or_edit_path_for_answer_type("name")).to eq(name_settings_new_path(form_id))
      end

      it "returns new question path for unknown answer types" do
        expect(service.new_or_edit_path_for_answer_type("unknown_type")).to eq(new_question_path(form_id))
      end

      it "returns new question path for nil answer type" do
        expect(service.new_or_edit_path_for_answer_type(nil)).to eq(new_question_path(form_id))
      end
    end

    context "when editing an existing page (existing_page_id present)" do
      subject(:service) { described_class.new(form_id: form_id, existing_page_id: page_id) }

      let(:page_id) { 456 }

      it "returns selection edit path for selection questions" do
        expect(service.new_or_edit_path_for_answer_type("selection")).to eq(selection_type_edit_path(form_id, page_id))
      end

      it "returns text settings edit path for text questions" do
        expect(service.new_or_edit_path_for_answer_type("text")).to eq(text_settings_edit_path(form_id, page_id))
      end

      it "returns date settings edit path for date questions" do
        expect(service.new_or_edit_path_for_answer_type("date")).to eq(date_settings_edit_path(form_id, page_id))
      end

      it "returns address settings edit path for address questions" do
        expect(service.new_or_edit_path_for_answer_type("address")).to eq(address_settings_edit_path(form_id, page_id))
      end

      it "returns name settings edit path for name questions" do
        expect(service.new_or_edit_path_for_answer_type("name")).to eq(name_settings_edit_path(form_id, page_id))
      end

      it "returns edit question path for unknown answer types" do
        expect(service.new_or_edit_path_for_answer_type("unknown_type")).to eq(edit_question_path(form_id, page_id))
      end

      it "returns nil question path for nil answer types" do
        expect(service.new_or_edit_path_for_answer_type(nil)).to eq(edit_question_path(form_id, page_id))
      end
    end
  end
end
