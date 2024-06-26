require "rails_helper"

RSpec.describe Forms::MarkCompleteInput, type: :model do
  let(:form) { build :form }
  let(:mark_complete_input) { described_class.new(mark_complete:, form:) }
  let(:mark_complete) { "true" }

  describe "validations" do
    context "when mark_complete is blank" do
      let(:mark_complete) { nil }

      it "is not valid" do
        expect(mark_complete_input).not_to be_valid
      end
    end

    context "when mark_complete is true" do
      let(:mark_complete) { "true" }

      it "is valid" do
        expect(mark_complete_input).to be_valid
      end
    end

    context "when mark_complete is false" do
      let(:mark_complete) { "false" }

      it "is valid" do
        expect(mark_complete_input).to be_valid
      end
    end

    context "when form has routing validation errors" do
      let(:form) { build :form, :ready_for_routing, has_routing_errors: true }

      context "when mark_complete is true" do
        let(:mark_complete) { "true" }

        it "is valid" do
          error_message = I18n.t("activemodel.errors.models.forms/mark_complete_input.attributes.base.has_routing_errors")
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
        allow(form).to receive(:save).and_return(true)
        allow(mark_complete_input).to receive_messages(invalid?: false, form:)
      end

      it "returns true if valid and form is updated" do
        expect(mark_complete_input.submit).to be true
      end

      it "sets the forms question section completed" do
        mark_complete_input.submit
        expect(mark_complete_input.form.question_section_completed).to eq mark_complete_input.mark_complete
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
      allow(form).to receive(:save!).and_return(true)
      allow(mark_complete_input).to receive_messages(invalid?: false, form:)
      expect(mark_complete_input.submit).to be true
    end

    context "when mark_complete_input form does not save" do
      before do
        allow(form).to receive(:save!).and_return(false)
        allow(mark_complete_input).to receive_messages(invalid?: false, form:)
      end

      it "returns false if invalid" do
        expect(mark_complete_input.submit).to be false
      end
    end
  end

  describe "marked_complete?" do
    context "when mark_complete is nil" do
      let(:mark_complete) { nil }

      it "returns false" do
        expect(mark_complete_input.marked_complete?).to be false
      end
    end

    context "when mark_complete is false" do
      let(:mark_complete) { "false" }

      it "returns false" do
        expect(mark_complete_input.marked_complete?).to be false
      end
    end

    context "when mark_complete is true" do
      let(:mark_complete) { "true" }

      it "returns false" do
        expect(mark_complete_input.marked_complete?).to be true
      end
    end
  end
end
