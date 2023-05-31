require "rails_helper"

RSpec.describe Forms::MarkCompleteForm, type: :model do
  let(:form) { build :form }
  let(:mark_complete_form) { described_class.new(mark_complete:, form:) }
  let(:mark_complete) { "true" }

  describe "validations" do
    context "when mark_complete is blank" do
      let(:mark_complete) { nil }

      it "is not valid" do
        expect(mark_complete_form).not_to be_valid
      end
    end

    context "when mark_complete is true" do
      let(:mark_complete) { "true" }

      it "is valid" do
        expect(mark_complete_form).to be_valid
      end
    end

    context "when mark_complete is false" do
      let(:mark_complete) { "false" }

      it "is valid" do
        expect(mark_complete_form).to be_valid
      end
    end

    context "when form has routing validation errors" do
      let(:form) { build :form, :ready_for_routing, has_routing_errors: true }

      context "when mark_complete is true" do
        let(:mark_complete) { "true" }

        it "is valid" do
          error_message = I18n.t("activemodel.errors.models.forms/mark_complete_form.attributes.base.has_routing_errors")
          expect(mark_complete_form).not_to be_valid
          expect(mark_complete_form.errors.full_messages_for(:base)).to include(error_message)
        end
      end

      context "when mark_complete is false" do
        let(:mark_complete) { "false" }

        it "is valid" do
          expect(mark_complete_form).to be_valid
        end
      end
    end
  end

  describe "#save" do
    context "when mark_complete_form is valid" do
      before do
        allow(mark_complete_form).to receive(:invalid?).and_return(false)
        allow(form).to receive(:save).and_return(true)
        allow(mark_complete_form).to receive(:form).and_return(form)
      end

      it "returns true if valid and form is updated" do
        expect(mark_complete_form.mark_section).to eq true
      end

      it "sets the forms question section completed" do
        mark_complete_form.mark_section
        expect(mark_complete_form.form.question_section_completed).to eq mark_complete_form.mark_complete
      end
    end

    context "when mark_complete_form is not valid" do
      before do
        allow(mark_complete_form).to receive(:invalid?).and_return(true)
      end

      it "returns false if invalid" do
        expect(mark_complete_form.mark_section).to eq false
      end

      it "does not set the forms question section completed" do
        mark_complete_form.mark_section
        expect(mark_complete_form.form.question_section_completed).not_to eq mark_complete_form.mark_complete
      end
    end

    it "returns true if valid and form is updated" do
      allow(mark_complete_form).to receive(:invalid?).and_return(false)
      allow(form).to receive(:save!).and_return(true)
      allow(mark_complete_form).to receive(:form).and_return(form)
      expect(mark_complete_form.mark_section).to eq true
    end

    context "when mark_complete_form form does not save" do
      before do
        allow(mark_complete_form).to receive(:invalid?).and_return(false)
        allow(form).to receive(:save!).and_return(false)
        allow(mark_complete_form).to receive(:form).and_return(form)
      end

      it "returns false if invalid" do
        expect(mark_complete_form.mark_section).to eq false
      end
    end
  end

  describe "marked_complete?" do
    context "when mark_complete is nil" do
      let(:mark_complete) { nil }

      it "returns false" do
        expect(mark_complete_form.marked_complete?).to eq false
      end
    end

    context "when mark_complete is false" do
      let(:mark_complete) { "false" }

      it "returns false" do
        expect(mark_complete_form.marked_complete?).to eq false
      end
    end

    context "when mark_complete is true" do
      let(:mark_complete) { "true" }

      it "returns false" do
        expect(mark_complete_form.marked_complete?).to eq true
      end
    end
  end
end
