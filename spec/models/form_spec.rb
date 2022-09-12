require "rails_helper"

describe Form do
  let(:form) { described_class.new(name: "Form 1", org: "Test org", live_at: "") }

  describe "#live?" do
    context "when form is draft" do
      it "return false" do
        form.live_at = ""
        expect(form.live?).to eq false
      end
    end

    context "when form is live" do
      it "return true" do
        form.live_at = "2021-01-01T00:00:00.000Z"
        expect(form.live?).to eq true
      end
    end

    context "when form is live in the future" do
      it "return false" do
        form.live_at = "2101-01-01T00:00:00.000Z"
        expect(form.live?).to eq false
      end
    end
  end

  describe "#status" do
    context "when form is draft (live_at not set)" do
      it "returns 'draft'" do
        form.live_at = ""
        expect(form.status).to eq "draft"
      end
    end

    context "when form is live (live_at is set)" do
      it "returns 'live'" do
        form.live_at = Time.zone.now.to_s
        expect(form.status).to eq "live"
      end
    end
  end
end
