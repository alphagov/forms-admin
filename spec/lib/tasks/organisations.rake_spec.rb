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

  describe "organisations:rename" do
    subject(:task) do
      Rake::Task["organisations:rename"]
        .tap(&:reenable) # make sure task is invoked every time
    end

    it "renames an organisation" do
      test_org = create :organisation, name: "Department for Testing", slug: "dft"
      test_org.clear_changes_information

      expect { task.invoke("Department for Testing", "Department for Testing and Validation") }
        .to output(/Renamed/).to_stdout

      expect(test_org.reload).to have_attributes(name: "Department for Testing and Validation")
    end

    it "does not rename an org from GOV.UK API" do
      test_org = create :organisation, name: "Department for Testing", slug: "dft", govuk_content_id: Faker::Internet.uuid
      test_org.clear_changes_information

      expect { task.invoke("Department for Testing", "Department of Nope") }
        .to output(/is from the GOV.UK API/).to_stderr
        .and raise_error(SystemExit) { |e| expect(e).not_to be_success }
    end

    it "does not rename non-existent organisations" do
      expect { task.invoke("Department for Testing", "Department for Testing and Validation") }
        .to output(/not found/).to_stderr
        .and raise_error(SystemExit) { |e| expect(e).not_to be_success }
    end
  end

  describe "organisations:merge" do
    subject(:task) do
      Rake::Task["organisations:merge"]
        .tap(&:reenable) # make sure task is invoked every time
    end

    let!(:source_org) { create :organisation, slug: "old-organisation", closed: true }
    let!(:target_org) { create :organisation, slug: "shiny-new-organisation" }

    it "moves users from one organisation to another" do
      create_list :user, 5, organisation: source_org

      expect {
        task.invoke("old-organisation", "shiny-new-organisation")
      }.to change(User.where(organisation: target_org), :count).by(5)
        .and change(User.where(organisation: source_org), :count).from(5).to(0)
    end

    it "moves groups from one organisation to another" do
      create_list :group, 5, organisation: source_org

      expect {
        task.invoke("old-organisation", "shiny-new-organisation")
      }.to change(Group.where(organisation: target_org), :count).by(5)
        .and change(Group.where(organisation: source_org), :count).from(5).to(0)
    end

    shared_examples "it does not move users or groups" do
      RSpec::Matchers.define_negated_matcher :not_change, :change

      it "does not move users from one organisation to another" do
        create_list :user, 5, organisation: source_org

        expect {
          invoked_task
        }.to not_change(User.where(organisation: target_org), :count)
          .and not_change(User.where(organisation: source_org), :count)
      end

      it "does not move groups from one organisation to another" do
        create_list :group, 5, organisation: source_org

        expect {
          invoked_task
        }.to not_change(Group.where(organisation: target_org), :count)
          .and not_change(Group.where(organisation: source_org), :count)
      end
    end

    context "when organisation to move users and groups from is not closed" do
      let!(:source_org) { create :organisation, slug: "old-organisation", closed: false }

      let(:invoked_task) do
        expect { # rubocop:disable RSpec/ExpectInLet
          task.invoke(source_org.slug, target_org.slug)
        }.to raise_error(SystemExit)
          .and output(/Old Organisation is not yet closed/).to_stderr
      end

      include_examples "it does not move users or groups"
    end

    context "when old organisation has signed mou but new organisation has not" do
      before do
        create :mou_signature_for_organisation, organisation: source_org
      end

      let(:invoked_task) do
        expect { # rubocop:disable RSpec/ExpectInLet
          task.invoke(source_org.slug, target_org.slug)
        }.to raise_error(SystemExit)
          .and output(/Old Organisation has signed MOU but Shiny New Organisation has not/).to_stderr
      end

      include_examples "it does not move users or groups"
    end

    context "when old organisation and new organisation have groups with the same name" do
      before do
        create :group, organisation: source_org, name: "Test group"
        create :group, organisation: target_org, name: "Test group"
      end

      let(:invoked_task) do
        expect { # rubocop:disable RSpec/ExpectInLet
          task.invoke(source_org.slug, target_org.slug)
        }.to raise_error(SystemExit)
          .and output(/there are some duplicate group names/).to_stderr
      end

      include_examples "it does not move users or groups"
    end

    describe ":dry_run" do
      subject(:task) do
        Rake::Task["organisations:merge:dry_run"]
          .tap(&:reenable) # make sure task is invoked every time
      end

      let(:invoked_task) do
        task.invoke(source_org.slug, target_org.slug)
      end

      include_examples "it does not move users or groups"
    end
  end
end
