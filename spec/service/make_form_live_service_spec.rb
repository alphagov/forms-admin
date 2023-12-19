require "rails_helper"

describe MakeFormLiveService do
  let(:make_form_live_service) { described_class.call(draft_form:) }
  let(:draft_form) { build :form, :ready_for_live, id: 1 }

  describe "#make_live" do
    before do
      allow(draft_form).to receive(:make_live!).and_return(true)
    end

    it "calls make_live! on the current form" do
      expect(draft_form).to receive(:make_live!)
      make_form_live_service.make_live
    end
  end
end
