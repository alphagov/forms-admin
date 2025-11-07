require "rake"
require "rails_helper"

RSpec.describe "data_migrations.rake" do
  before do
    Rake.application.rake_require "tasks/data_migrations"
    Rake::Task.define_task(:environment)
    allow($stdout).to receive(:puts) # to prevent logs printing during tests
  end

  describe "data_migrations:set_page_external_ids" do
    subject(:task) do
      Rake::Task["data_migrations:set_page_external_ids"]
        .tap(&:reenable)
    end

    let(:form) { create(:form, :ready_for_live, pages_count: 2) }
    let(:form_with_page_external_ids) { create(:form, :live, pages_count: 2) }

    before do
      form.pages.each { |page| page.update!(external_id: nil) }
      form.make_live!
    end

    it "sets external ID for pages where one does not exist" do
      task.invoke
      expect(form.pages[0].reload.external_id).not_to be_nil
      expect(form.pages[1].reload.external_id).not_to be_nil
    end

    it "sets the external ID in the draft form document" do
      task.invoke
      form_document_steps = form.draft_form_document.reload.content["steps"]
      expect(form_document_steps.map { |step| step["external_id"] }).not_to include(nil)
      expect(form_document_steps[0]["external_id"]).to eq(form.pages[0].reload.external_id)
      expect(form_document_steps[1]["external_id"]).to eq(form.pages[1].reload.external_id)
    end

    it "sets the external ID in the live form document" do
      task.invoke
      form_document_steps = form.live_form_document.reload.content["steps"]
      expect(form_document_steps.map { |step| step["external_id"] }).not_to include(nil)
      expect(form_document_steps[0]["external_id"]).to eq(form.pages[0].reload.external_id)
      expect(form_document_steps[1]["external_id"]).to eq(form.pages[1].reload.external_id)
    end

    it "does not update pages that already have an external ID" do
      expect {
        task.invoke
      }.not_to(change { form_with_page_external_ids.pages[0].reload.external_id })
    end

    it "does not change the form document when pages already have an external ID" do
      expect {
        task.invoke
      }.not_to(change { form_with_page_external_ids.live_form_document.reload.content })
    end

    context "when a page that exists in the live form has been removed from the draft form" do
      before do
        form.pages[0].destroy!
      end

      it "generates a new external ID for the step" do
        task.invoke
        form_document_steps = form.live_form_document.reload.content["steps"]
        expect(form_document_steps.map { |step| step["external_id"] }).not_to include(nil)
      end
    end
  end
end
