require "rails_helper"

RSpec.describe FormDocumentSyncService do
  let(:service) { described_class.new(form) }
  let(:form) { create(:form) }

  describe "#synchronize_live_form" do
    let!(:form) { create(:form, state: "live") }
    let(:expected_live_at) { form.reload.updated_at.as_json }

    context "when there is no existing form document" do
      it "creates a live form document" do
        expect {
          service.synchronize_live_form
        }.to change(FormDocument, :count).by(1)

        expect(FormDocument.last).to have_attributes(form:, tag: "live", content: form.as_form_document(live_at: expected_live_at))
      end
    end

    context "when there is an existing live form document" do
      let!(:form_document) { create :form_document, :live, form:, content: form.as_form_document }

      it "updates the live form document" do
        new_name = "new name"
        form.name = new_name
        expect {
          service.synchronize_live_form
        }.to change { form_document.reload.content["name"] }.to(new_name)
      end

      it "updates the live_at date in the form document" do
        service.synchronize_live_form
        expect(FormDocument.last["content"]).to include("live_at" => form.reload.updated_at.as_json)
      end
    end

    context "when there is an existing archived form document" do
      before do
        create :form_document, :archived, form:
      end

      it "destroys the archived form document" do
        expect {
          service.synchronize_live_form
        }.to(change { FormDocument.exists?(form:, tag: "archived") }.from(true).to(false))
      end

      it "creates the live form document" do
        expect {
          service.synchronize_live_form
        }.to(change { FormDocument.exists?(form:, tag: "live") }.from(false).to(true))
      end
    end
  end

  describe "#synchronize_archived_form" do
    context "when there is no existing live form document" do
      it "raises an ActiveRecord::RecordNotFound error" do
        expect {
          service.synchronize_archived_form
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when there is an existing live form document" do
      let!(:live_form_document) { create :form_document, :live, form:, content: "content" }

      it "destroys the live form document" do
        expect {
          service.synchronize_archived_form
        }.to(change { FormDocument.exists?(form:, tag: "live") }.from(true).to(false))
      end

      it "creates the archived form document" do
        expect {
          service.synchronize_archived_form
        }.to(change { FormDocument.exists?(form:, tag: "archived", content: live_form_document.content) }.from(false).to(true))
      end
    end

    context "when there is an existing archived form document" do
      before do
        create :form_document, :live, form:, content: "live content"
        create :form_document, :archived, form:, content: "old archived content"
      end

      it "replaces the archived form document" do
        service.synchronize_archived_form
        expect(FormDocument.find_by!(form:, tag: "archived").content).to eq("live content")
      end
    end
  end

  describe "#update_draft_form_document" do
    context "when there is no draft form document" do
      before do
        form.draft_form_document.destroy
      end

      it "creates a draft form document" do
        expect {
          service.update_draft_form_document
        }.to(change { FormDocument.exists?(form:, tag: "draft") }.from(false).to(true))
      end
    end

    context "when there is a draft form document" do
      let!(:form_document) { form.draft_form_document }
      let(:new_name) { "new name" }

      before do
        form.name = new_name
      end

      it "updates the draft form document" do
        expect {
          service.update_draft_form_document
        }.to change { form_document.reload.content["name"] }.to(new_name)
      end

      context "when there is also a live form document" do
        let!(:live_form_document) { create :form_document, :live, form:, content: "content" }

        it "does not modify the live form document" do
          expect {
            service.update_draft_form_document
          }.not_to(change { live_form_document.reload.content })
        end
      end
    end
  end
end
