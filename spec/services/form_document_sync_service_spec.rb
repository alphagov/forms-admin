require "rails_helper"

RSpec.describe FormDocumentSyncService do
  let(:service) { described_class }
  let(:form) { create(:form) }

  describe "#synchronize_form" do
    context "when form state is live" do
      let(:form) { create(:form, :live) }

      context "when there is no existing form document" do
        it "creates a live form document" do
          expect {
            service.synchronize_form(form)
          }.to change(FormDocument, :count).by(1)

          expect(FormDocument.last).to have_attributes(form:, tag: "live", content: form.as_form_document)
        end
      end

      context "when there is an existing live form document" do
        let!(:form_document) { create :form_document, :live, form: }

        it "updates the live form document" do
          expect {
            service.synchronize_form(form)
          }.to change { form_document.reload.content }.to(form.as_form_document)
        end
      end

      context "when there is an existing archived form document" do
        before do
          create :form_document, :archived, form:
        end

        it "destroys the archived form document" do
          expect {
            service.synchronize_form(form)
          }.to(change { FormDocument.exists?(form:, tag: "archived") })
        end

        it "creates the live form document" do
          expect {
            service.synchronize_form(form)
          }.to(change { FormDocument.exists?(form:, tag: "live", content: form.as_form_document) })
        end
      end
    end

    context "when form state is archived" do
      let(:form) { create(:form, :archived) }

      context "when there is no existing form document" do
        it "creates an archived form document" do
          allow(ApiFormDocumentService).to receive(:form_document).with(form_id: form.id, tag: "live").and_return(form.as_form_document)

          expect {
            service.synchronize_form(form)
          }.to change(FormDocument, :count).by(1)

          expect(FormDocument.last).to have_attributes(form:, tag: "archived", content: form.as_form_document)
        end
      end

      context "when there is an existing live form document" do
        let!(:live_form_document) { create :form_document, :live, form:, content: "content" }

        it "destroys the live form document" do
          expect {
            service.synchronize_form(form)
          }.to(change { FormDocument.exists?(form:, tag: "live") })
        end

        it "creates the archived form document" do
          expect {
            service.synchronize_form(form)
          }.to(change { FormDocument.exists?(form:, tag: "archived", content: live_form_document.content) })
        end
      end
    end
  end
end
