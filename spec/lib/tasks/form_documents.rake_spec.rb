require "rake"
require "rails_helper"

RSpec.describe "form_documents.rake" do
  before do
    Rake.application.rake_require "tasks/form_documents"
    Rake::Task.define_task(:environment)
    allow($stdout).to receive(:puts) # to prevent logs printing during tests
  end

  describe "form_documents:sync" do
    subject(:task) do
      Rake::Task["form_documents:sync"]
        .tap(&:reenable)
    end

    context "when there is a draft form locally" do
      before do
        create :form, :draft
      end

      it "does not add a FormDocument" do
        expect {
          task.invoke
        }.not_to(change(FormDocument, :count))
      end
    end

    context "when there is a live form locally" do
      let(:live_form) { create :form, :live }

      before do
        allow(ApiFormDocumentService).to receive(:form_document).with(form_id: live_form.id, tag: "live").and_return("content")
      end

      it "calls the ApiFormDocumentService" do
        task.invoke
        expect(ApiFormDocumentService).to have_received(:form_document)
      end

      it "creates a FormDocument for the form" do
        expect {
          task.invoke
        }.to(change { FormDocument.exists?(form_id: live_form.id, tag: "live") })
      end

      context "when there is already a live FormDocument for the form" do
        before do
          create :form_document, :live, form: live_form
        end

        it "does not affect the existing FormDocument" do
          expect {
            task.invoke
          }.not_to(change { FormDocument.exists?(form_id: live_form.id, tag: "live") })
        end
      end
    end

    context "when there is a live_with_draft form locally" do
      let(:live_form) { create :form, :live_with_draft }

      before do
        allow(ApiFormDocumentService).to receive(:form_document).with(form_id: live_form.id, tag: "live").and_return("content")
      end

      it "calls the ApiFormDocumentService" do
        task.invoke
        expect(ApiFormDocumentService).to have_received(:form_document)
      end

      it "creates a FormDocument for the form" do
        expect {
          task.invoke
        }.to(change { FormDocument.exists?(form_id: live_form.id, tag: "live") })
      end

      context "when there is already a live FormDocument for the form" do
        before do
          create :form_document, :live, form: live_form
        end

        it "does not affect the existing FormDocument" do
          expect {
            task.invoke
          }.not_to(change { FormDocument.exists?(form_id: live_form.id, tag: "live") })
        end
      end
    end

    context "when there is an archived form locally" do
      let(:archived_form) { create :form, :archived }

      before do
        allow(ApiFormDocumentService).to receive(:form_document).with(form_id: archived_form.id, tag: "archived").and_return("content")
      end

      it "calls the ApiFormDocumentService" do
        task.invoke
        expect(ApiFormDocumentService).to have_received(:form_document)
      end

      it "creates a FormDocument for the form" do
        expect {
          task.invoke
        }.to(change { FormDocument.exists?(form_id: archived_form.id, tag: "archived") })
      end

      context "when there is already a live FormDocument for the form" do
        before do
          create :form_document, :archived, form: archived_form
        end

        it "does not affect the existing FormDocument" do
          expect {
            task.invoke
          }.not_to(change { FormDocument.exists?(form_id: archived_form.id, tag: "archived") })
        end
      end
    end

    context "when there is an archived_with_draft form locally" do
      let(:archived_form) { create :form, :archived_with_draft }

      before do
        allow(ApiFormDocumentService).to receive(:form_document).with(form_id: archived_form.id, tag: "archived").and_return("content")
      end

      it "calls the ApiFormDocumentService" do
        task.invoke
        expect(ApiFormDocumentService).to have_received(:form_document)
      end

      it "creates a FormDocument for the form" do
        expect {
          task.invoke
        }.to(change { FormDocument.exists?(form_id: archived_form.id, tag: "archived") })
      end

      context "when there is already a live FormDocument for the form" do
        before do
          create :form_document, :archived, form: archived_form
        end

        it "does not affect the existing FormDocument" do
          expect {
            task.invoke
          }.not_to(change { FormDocument.exists?(form_id: archived_form.id, tag: "archived") })
        end
      end
    end
  end

  describe "form_documents:sync_dry_run" do
    subject(:task) do
      Rake::Task["form_documents:sync_dry_run"]
        .tap(&:reenable)
    end

    context "when there is a live form locally" do
      let(:form) { create :form, :live }

      before do
        allow(ApiFormDocumentService).to receive(:form_document).with(form_id: form.id, tag: "live").and_return("content")
      end

      it "calls the ApiFormDocumentService" do
        task.invoke
        expect(ApiFormDocumentService).to have_received(:form_document)
      end

      it "does not add a FormDocument" do
        expect {
          task.invoke
        }.not_to(change(FormDocument, :count))
      end
    end
  end
end
