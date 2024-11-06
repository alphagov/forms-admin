require "rails_helper"

RSpec.describe PagesHelper, type: :helper do
  let(:page_id) { 2 }
  let(:draft_question) { build :draft_question, page_id: }

  describe "#selection_options_new_path_for_draft_question" do
    context "when draft_question has no answer_settings" do
      it "returns options path" do
        expect(helper.selection_options_new_path_for_draft_question(draft_question))
          .to eq(long_lists_selection_options_new_path(form_id: draft_question.form_id))
      end
    end

    context "when draft_question has 30 selection options" do
      let(:selection_options) { (1..30).to_a.map { |i| { name: i.to_s } } }
      let(:draft_question) { build :draft_question, answer_settings: { selection_options: } }

      it "returns options path" do
        expect(helper.selection_options_new_path_for_draft_question(draft_question))
          .to eq(long_lists_selection_options_new_path(form_id: draft_question.form_id))
      end
    end

    context "when draft_question has more than 30 selection options" do
      let(:selection_options) { (1..31).to_a.map { |i| { name: i.to_s } } }
      let(:draft_question) { build :draft_question, answer_settings: { selection_options: } }

      it "returns bulk options path" do
        expect(helper.selection_options_new_path_for_draft_question(draft_question))
          .to eq(long_lists_selection_bulk_options_new_path(form_id: draft_question.form_id))
      end
    end
  end

  describe "#selection_options_edit_path_for_draft_question" do
    context "when draft_question has no answer_settings" do
      it "returns options path" do
        expect(helper.selection_options_edit_path_for_draft_question(draft_question))
          .to eq(long_lists_selection_options_edit_path(form_id: draft_question.form_id, page_id:))
      end
    end

    context "when draft_question has 30 selection options" do
      let(:selection_options) { (1..30).to_a.map { |i| { name: i.to_s } } }
      let(:draft_question) { build :draft_question, page_id:, answer_settings: { selection_options: } }

      it "returns options path" do
        expect(helper.selection_options_edit_path_for_draft_question(draft_question))
          .to eq(long_lists_selection_options_edit_path(form_id: draft_question.form_id, page_id:))
      end
    end

    context "when draft_question has more than 30 selection options" do
      let(:selection_options) { (1..31).to_a.map { |i| { name: i.to_s } } }
      let(:draft_question) { build :draft_question, page_id:, answer_settings: { selection_options: } }

      it "returns bulk options path" do
        expect(helper.selection_options_edit_path_for_draft_question(draft_question))
          .to eq(long_lists_selection_bulk_options_edit_path(form_id: draft_question.form_id, page_id:))
      end
    end
  end
end
