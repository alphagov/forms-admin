require "rails_helper"

describe FormService do
  subject(:form_service) do
    described_class.new(form)
  end

  let(:id) { 1 }
  let(:form) { build(:form, id:) }

  describe "#path_for_state" do
    context "when form is live" do
      before do
        form.state = :live
      end

      it "returns live form path" do
        expect(form_service.path_for_state).to eq "/forms/#{id}/live"
      end
    end

    context "when form is archived" do
      before do
        form.state = :archived
      end

      it "returns archived form path" do
        expect(form_service.path_for_state).to eq "/forms/#{id}/archived"
      end
    end

    context "when form is draft" do
      before do
        form.state = :draft
      end

      it "returns draft form path" do
        expect(form_service.path_for_state).to eq "/forms/#{id}"
      end
    end
  end
end
