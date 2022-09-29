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

  describe "#ready_for_live?" do
    context "when a form is complete and ready to be made live" do
      let(:completed_form) { build :form, :with_pages, :live }

      it "returns true" do
        expect(completed_form.ready_for_live?).to eq true
      end

      it "returns no missing fields" do
        results = completed_form
        results.ready_for_live?

        expect(results.missing_sections).to be_empty
      end
    end

    context "when a form is incomplete and should still be in draft state" do
      let(:new_form) { build :form, :new_form }

      it "returns false" do
        new_form.pages = []
        expect(new_form.ready_for_live?).to eq false
      end

      it "returns a set of keys related to missing fields" do
        new_form.pages = []
        results = new_form
        results.ready_for_live?

        expect(results.missing_sections).to eq %i[missing_pages missing_submission_email missing_privacy_policy_url]
      end
    end
  end
end
