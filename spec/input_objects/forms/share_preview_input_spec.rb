require "rails_helper"

RSpec.describe Forms::SharePreviewInput, type: :model do
  let(:form) { build :form }
  let(:mark_complete_input) { described_class.new(mark_complete:, form:) }
  let(:mark_complete) { "true" }

  describe "#save" do
    context "when valid" do
      before do
        allow(form).to receive(:save).and_return(true)
        allow(mark_complete_input).to receive_messages(invalid?: false, form:)
      end

      it "returns true if valid and form is updated" do
        expect(mark_complete_input.submit).to be true
      end

      it "sets the forms question section completed" do
        mark_complete_input.submit
        expect(mark_complete_input.form.share_preview_completed).to eq mark_complete_input.mark_complete
      end
    end

    context "when invalid" do
      before do
        allow(mark_complete_input).to receive(:invalid?).and_return(true)
      end

      it "returns false if invalid" do
        expect(mark_complete_input.submit).to be false
      end

      it "does not set the forms question section completed" do
        mark_complete_input.submit
        expect(mark_complete_input.form.share_preview_completed).not_to eq mark_complete_input.mark_complete
      end
    end
  end

  describe("#assign_form_values") do
    context "when task is completed" do
      let(:form) { build :form, share_preview_completed: true }

      it "sets mark_complete to true" do
        mark_complete_input.assign_form_values
        expect(mark_complete_input.mark_complete).to be true
      end
    end

    context "when task is not completed" do
      let(:form) { build :form, share_preview_completed: false }

      it "sets mark_complete to false" do
        mark_complete_input.assign_form_values
        expect(mark_complete_input.mark_complete).to be false
      end
    end
  end
end
