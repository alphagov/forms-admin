require "rake"

require "rails_helper"

RSpec.describe "mou_signatures.rake" do
  before do
    Rake.application.rake_require "tasks/mou_signatures"
    Rake::Task.define_task(:environment)
  end

  describe "mou_signatures:create" do
    subject(:task) do
      Rake::Task["mou_signatures:create"]
        .tap(&:reenable) # make sure task is invoked every time
    end

    let(:user) { create :user, name: "A Person" }
    let(:organisation) { create :organisation, slug: "government-digital-service" }
    let(:date) { Date.iso8601 "2020-01-01T00:00" }

    it "aborts when the user is not found" do
      expect { task.invoke("John Doe", organisation.name, date.iso8601) }
        .to raise_error(ActiveRecord::RecordNotFound, /Couldn't find User/)
    end

    it "aborts when the organisation is not found" do
      expect { task.invoke(user.email, "GDS", date.iso8601) }
        .to raise_error(ActiveRecord::RecordNotFound, /Couldn't find Organisation/)
    end

    it "aborts when the agreed at date is not a valid date" do
      expect { task.invoke(user.email, organisation.name, "not a date") }
        .to raise_error(Date::Error, /invalid date/)
    end

    it "creates an MOU signature" do
      freeze_time do
        expect { task.invoke(user.email, organisation.name, date.iso8601) }
          .to change(MouSignature, :count).by(1)
          .and output(/Added MOU signature for User: A Person and Organisation: Government Digital Service signed at: 2020-01-01 00:00/).to_stdout

        expect(MouSignature.last).to have_attributes(user:, organisation:, created_at: date, updated_at: Time.zone.now)
      end
    end
  end

  describe "mou_signatures:update_organisation" do
    subject(:task) do
      Rake::Task["mou_signatures:update_organisation"]
        .tap(&:reenable) # make sure task is invoked every time
    end

    let(:user) { create :user }
    let(:current_organisation) { create :organisation, slug: "government-digital-service" }
    let(:target_organisation) { create :organisation, slug: "cabinet-office" }
    let(:mou_signature) { create :mou_signature, user:, organisation: current_organisation }

    it "aborts when the user is not found" do
      expect { task.invoke("John Doe", current_organisation.name, target_organisation.name) }
        .to output(/User with name: John Doe not found/)
              .to_stderr
              .and raise_error(SystemExit) { |e| expect(e).not_to be_success }
    end

    it "aborts when the current organisation is not found" do
      expect { task.invoke(user.name, "GDS", target_organisation.name) }
        .to output(/Organisation with name: GDS not found/)
              .to_stderr
              .and raise_error(SystemExit) { |e| expect(e).not_to be_success }
    end

    it "aborts when the target organisation is not found" do
      expect { task.invoke(user.name, current_organisation.name, "GDS") }
        .to output(/Organisation with name: GDS not found/)
              .to_stderr
              .and raise_error(SystemExit) { |e| expect(e).not_to be_success }
    end

    it "aborts when an MOU signature is not found for the user and organisation" do
      expect { task.invoke(user.name, target_organisation.name, current_organisation.name) }
        .to output(/MOU signature for User:/)
              .to_stderr
              .and raise_error(SystemExit) { |e| expect(e).not_to be_success }
    end

    it "updates the organisation for an MOU" do
      mou_signature
      expect { task.invoke(user.name, current_organisation.name, target_organisation.name) }
        .to change { mou_signature.reload.organisation }.to(target_organisation)
        .and output(/Updated MOU signature/)
              .to_stdout
    end
  end
end
