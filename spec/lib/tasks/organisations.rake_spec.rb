require "rake"

require "rails_helper"

RSpec.describe "organisations.rake" do
  before do
    Rake.application.rake_require "tasks/organisations"
    Rake::Task.define_task(:environment)
  end

  describe "organisations:create" do
    subject(:task) do
      Rake::Task["organisations:create"]
        .tap(&:reenable) # make sure task is invoked every time
    end

    it "creates an organisation" do
      expect(Organisation.find_by(name: "Global Test Organisation"))
        .to be_nil

      expect { task.invoke("Global Test Organisation") }.to output(/Created/).to_stdout

      expect(Organisation.find_by(name: "Global Test Organisation"))
        .to be_truthy
    end

    it "does not recreate already existing organisations" do
      test_org = create :organisation, name: "Department for Testing", slug: "dft", govuk_content_id: Faker::Internet.uuid
      test_org.clear_changes_information

      expect { task.invoke("Department for Testing") }
        .to output(/already exists/).to_stderr
        .and raise_error(SystemExit) { |e| expect(e).not_to be_success }

      expect(test_org.previous_changes).to be_empty
    end

    [
      ["Global Test Organisation", "global-test-organisation"],
      ["Testing, Validating and Verifying Service", "testing-validating-and-verifying-service"],
      ["Head Tester’s Department", "head-tester-s-department"],
    ].each do |name, slug|
      describe "given organisation name \"#{name}\"" do
        it "generates the organisation slug \"#{slug}\"" do
          expect { task.invoke(name) }.to output(/Created/).to_stdout

          expect(Organisation.find_by(name:))
            .to have_attributes(slug:)
        end
      end
    end
  end

  describe "organisations:fetch" do
    subject(:task) do
      Rake::Task["organisations:fetch"]
        .tap(&:reenable) # make sure task is invoked every time
    end

    it "fetches organisations" do
      organisations_fetcher = instance_double(OrganisationsFetcher)
      allow(organisations_fetcher).to receive(:call).and_return(nil)
      allow(OrganisationsFetcher).to receive(:new).and_return(organisations_fetcher)

      task.invoke

      expect(organisations_fetcher).to have_received(:call).once
    end
  end
end
