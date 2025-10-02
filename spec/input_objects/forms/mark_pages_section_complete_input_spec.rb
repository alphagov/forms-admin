require "rails_helper"

RSpec.describe Forms::MarkPagesSectionCompleteInput, type: :model do
  let(:form) { create :form }
  let(:mark_complete_input) { described_class.new(mark_complete:, form:) }
  let(:mark_complete) { "true" }

  describe "validations" do
    context "when form has routing validation errors" do
      let(:form) { create :form, :ready_for_routing }

      before do
        create :condition, routing_page_id: form.pages.first.id, check_page_id: form.pages.first.id, goto_page_id: form.pages.third.id, answer_value: "Doesn't exist"
        form.reload
      end

      context "when mark_complete is true" do
        let(:mark_complete) { "true" }

        it "is not valid" do
          error_message = I18n.t("activemodel.errors.models.forms/mark_pages_section_complete_input.attributes.base.has_routing_errors")
          expect(mark_complete_input).not_to be_valid
          expect(mark_complete_input.errors.full_messages_for(:base)).to include(error_message)
        end
      end

      context "when mark_complete is false" do
        let(:mark_complete) { "false" }

        it "is valid" do
          expect(mark_complete_input).to be_valid
        end
      end
    end
  end

  describe "#save" do
    context "when mark_complete_input is valid" do
      before do
        allow(mark_complete_input).to receive_messages(invalid?: false, form:)
      end

      it "returns true if valid and form is updated" do
        expect(mark_complete_input.submit).to be true
      end

      it "sets the forms question section completed" do
        mark_complete_input.submit
        expect(mark_complete_input.form.question_section_completed).to be true
      end
    end

    context "when mark_complete_input is not valid" do
      before do
        allow(mark_complete_input).to receive(:invalid?).and_return(true)
      end

      it "returns false if invalid" do
        expect(mark_complete_input.submit).to be false
      end

      it "does not set the forms question section completed" do
        mark_complete_input.submit
        expect(mark_complete_input.form.question_section_completed).not_to eq mark_complete_input.mark_complete
      end
    end

    it "returns true if valid and form is updated" do
      allow(mark_complete_input).to receive_messages(invalid?: false, form:)
      expect(mark_complete_input.submit).to be true
    end
  end
end
