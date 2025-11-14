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
end
