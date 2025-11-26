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

      context "and deleting the archived FormDocument fails" do
        before do
          allow(service).to receive(:delete_form_documents_by_tag).with(FormDocumentSyncService::ARCHIVED_TAG)
            .and_raise(ActiveRecord::StatementInvalid)
        end

        it "does not create the live FormDocument" do
          expect {
            service.synchronize_live_form
          }.to raise_error(ActiveRecord::StatementInvalid).and not_change(FormDocument, :count)
        end
      end
    end

    context "when the form has welsh translations" do
      let(:form) { create(:form, state: "live", available_languages: %w[en cy]) }

      it "creates a draft form document for each language" do
        expect {
          service.synchronize_live_form
        }.to change(FormDocument, :count).by(2)

        expect(FormDocument.where(form:, tag: "draft", language: "en")).to exist
        expect(FormDocument.where(form:, tag: "draft", language: "cy")).to exist
      end

      context "and the English form fails to save" do
        before do
          allow(service).to receive(:update_or_create_form_document).and_call_original
          # saving welsh form fails
          allow(service).to receive(:update_or_create_form_document)
            .with("live", anything, "cy")
            .and_raise(ActiveRecord::RecordInvalid.new(form), "simulated FormDocument saving error")
        end

        it "does not create any FormDocuments" do
          expect {
            service.synchronize_live_form
          }.to raise_error(ActiveRecord::RecordInvalid).and not_change(FormDocument, :count)
        end
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

      context "when the live FormDocument fails to delete" do
        before do
          allow(service).to receive(:delete_form_documents_by_tag).and_call_original
          allow(service).to receive(:delete_form_documents_by_tag).with(FormDocumentSyncService::ARCHIVED_TAG)
            .and_raise(ActiveRecord::RecordInvalid.new(live_form_document), "simulated FormDocument deleting error")
        end

        it "does not create the live FormDocument" do
          expect {
            service.synchronize_archived_form
          }.to raise_error(ActiveRecord::RecordInvalid).and not_change(FormDocument, :count)
        end
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

      context "and deleting the existing archived FormDocuments fails" do
        before do
          allow(service).to receive(:delete_form_documents_by_tag).with(FormDocumentSyncService::ARCHIVED_TAG)
            .and_raise(ActiveRecord::StatementInvalid)
        end

        it "does not change the archived FormDocument" do
          expect {
            service.synchronize_archived_form
          }.to raise_error(ActiveRecord::StatementInvalid).and(not_change { form.reload.archived_form_document.content })
        end
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

      context "when there is a draft form document in welsh" do
        before do
          create :form_document, :draft, form:, content: "content", language: "cy"
        end

        it "removes the draft form document in welsh" do
          expect {
            service.update_draft_form_document
          }.to(change { FormDocument.exists?(form:, tag: "draft", language: "cy") }.from(true).to(false))
        end
      end
    end
  end
end
