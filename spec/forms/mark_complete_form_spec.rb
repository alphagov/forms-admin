require "rails_helper"

RSpec.describe Forms::MarkCompleteForm, type: :model do
  describe "validations" do
    it "is not valid if blank" do
      mark_complete_form = described_class.new(mark_complete: nil)

      expect(mark_complete_form).not_to be_valid
    end

    it "is valid if true" do
      mark_complete_form = described_class.new(mark_complete: "true")

      expect(mark_complete_form).to be_valid
    end

    it "is valid if false" do
      mark_complete_form = described_class.new(mark_complete: "false")

      expect(mark_complete_form).to be_valid
    end
  end

  describe "#save" do
    let(:form) { build :form }
    let(:mark_complete_form) { described_class.new(mark_complete: "true", form:) }

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
end
