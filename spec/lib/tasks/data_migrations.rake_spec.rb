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

    let(:form) { create(:form, :live, pages_count: 2) }
    let(:form_with_page_external_ids) { create(:form, :live, pages_count: 2) }

    before do
      form.pages.each { |page| page.update!(external_id: nil) }
    end

    it "sets external ID for pages where one does not exist" do
      task.invoke
      expect(form.pages[0].reload.external_id).not_to be_nil
      expect(form.pages[1].reload.external_id).not_to be_nil
    end

    it "does not update pages that already have an external ID" do
      expect {
        task.invoke
      }.not_to(change { form_with_page_external_ids.pages[0].reload.external_id })
    end
  end

  describe "data_migrations:update_form_documents_to_use_external_ids" do
    subject(:task) do
      Rake::Task["data_migrations:update_form_documents_to_use_external_ids"]
        .tap(&:reenable)
    end

    let(:form) { create(:form, :ready_for_live, :ready_for_routing, pages_count: 3) }

    context "when the FormDocument hasn't already been updated" do
      before do
        create(:condition, routing_page: form.pages[0], check_page: form.pages[0], goto_page: form.pages[2], answer_value: "Option 1")
        form.reload.make_live!
        reset_ids_in_form_document(form.draft_form_document)
        reset_ids_in_form_document(form.live_form_document)
      end

      it "updates the form document" do
        expect {
          task.invoke
        }.to change { form.draft_form_document.reload.content["start_page"] }.from(form.pages[0].id).to(form.pages[0].external_id)
      end

      it "updates the ids in the draft form document to be the page external IDs" do
        task.invoke
        form_document_steps = form.draft_form_document.reload.content["steps"]
        expect(form_document_steps[0]["id"]).to eq(form.pages[0].external_id)
        expect(form_document_steps[1]["id"]).to eq(form.pages[1].external_id)
        expect(form_document_steps[2]["id"]).to eq(form.pages[2].external_id)
      end

      it "updates the next_step_ids in the draft form document to be the page external IDs" do
        task.invoke
        form_document_steps = form.draft_form_document.reload.content["steps"]
        expect(form_document_steps[0]["next_step_id"]).to eq(form.pages[1].external_id)
        expect(form_document_steps[1]["next_step_id"]).to eq(form.pages[2].external_id)
        expect(form_document_steps[2]["next_step_id"]).to be_nil
      end

      it "sets the database_id attribute for all steps" do
        task.invoke
        form_document_steps = form.draft_form_document.reload.content["steps"]
        expect(form_document_steps[0]["database_id"]).to eq(form.pages[0].id)
        expect(form_document_steps[1]["database_id"]).to eq(form.pages[1].id)
        expect(form_document_steps[2]["database_id"]).to eq(form.pages[2].id)
      end

      it "updates conditions to use page external IDs" do
        task.invoke
        form_document_steps = form.draft_form_document.reload.content["steps"]
        condition = form_document_steps[0]["routing_conditions"][0]
        expect(condition["routing_page_id"]).to eq(form.pages[0].external_id)
        expect(condition["check_page_id"]).to eq(form.pages[0].external_id)
        expect(condition["goto_page_id"]).to eq(form.pages[2].external_id)
      end

      it "updates the steps in the live form document" do
        task.invoke
        form_document_steps = form.live_form_document.reload.content["steps"]
        expect(form_document_steps[0]["id"]).to eq(form.pages[0].external_id)
      end

      context "when a page that exists in the live form has been removed from the draft form" do
        let(:deleted_page) { form.pages[1] }
        let(:deleted_page_id) { deleted_page.id }

        before do
          deleted_page.destroy!
          task.invoke
        end

        it "sets the ID for the removed page to be a newly generated external ID" do
          form_document_steps = form.live_form_document.reload.content["steps"]
          expect(form_document_steps[1]["id"]).not_to eq(deleted_page_id)
          expect(form_document_steps[1]["id"]).to be_a(String)
          expect(form_document_steps[1]["id"].length).to eq(8)
        end

        it "sets the database_id to be the old internal id" do
          form_document_steps = form.live_form_document.reload.content["steps"]
          expect(form_document_steps[1]["database_id"]).to eq(deleted_page_id)
        end

        it "sets the next_step_id for the previous step to be the newly generated external ID" do
          form_document_steps = form.draft_form_document.reload.content["steps"]
          expect(form_document_steps[0]["next_step_id"]).to eq(form_document_steps[1]["id"])
        end
      end
    end

    context "when the FormDocument has already been updated" do
      let(:form) { create(:form, :live) }

      it "does not change the form document" do
        expect {
          task.invoke
        }.not_to(change { form.live_form_document.reload.content })
      end
    end
  end

  def reset_ids_in_form_document(form_document)
    form_document.content["start_page"] = form.pages[0].id
    form_document.content["steps"].each_with_index do |step, index|
      step["id"] = form.pages[index].id
      step["next_step_id"] = form.pages[index + 1].id if index < form.pages.size - 1
      step.delete("database_id")
      step["routing_conditions"].each do |condition|
        condition["routing_page_id"] = form.pages.select { |p| p.external_id == condition["routing_page_id"] }.first.id
        condition["check_page_id"] = form.pages.select { |p| p.external_id == condition["check_page_id"] }.first.id
        condition["goto_page_id"] = form.pages.select { |p| p.external_id == condition["goto_page_id"] }.first.id
      end
    end
    form_document.save!
  end
end
