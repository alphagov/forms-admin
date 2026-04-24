require "rails_helper"

RSpec.describe "mou_signatures.rake", type: :task do
  describe "mou_signatures:create" do
    subject(:task) do
      Rake::Task["mou_signatures:create"]
    end

    let(:user) { create :user, name: "A Person" }
    let(:organisation) { create :organisation, slug: "government-digital-service" }
    let(:date) { Date.iso8601 "2020-01-01T00:00" }

    it "aborts when the user is not found" do
      expect { task.invoke("John Doe", organisation.name, date.iso8601, "crown") }
        .to raise_error(ActiveRecord::RecordNotFound, /Couldn't find User/)
    end

    it "aborts when the organisation is not found" do
      expect { task.invoke(user.email, "GDS", date.iso8601, "crown") }
        .to raise_error(ActiveRecord::RecordNotFound, /Couldn't find Organisation/)
    end

    it "aborts when the agreed at date is not a valid date" do
      expect { task.invoke(user.email, organisation.name, "not a date", "crown") }
        .to raise_error(Date::Error, /invalid date/)
    end

    it "creates an MOU signature" do
      freeze_time do
        expect { task.invoke(user.email, organisation.name, date.iso8601, "crown") }
          .to change(MouSignature, :count).by(1)
          .and output(/Added MOU signature for User: A Person and Organisation: Government Digital Service signed at: 2020-01-01 00:00/).to_stdout

        expect(MouSignature.last).to have_attributes(
          user:,
          organisation:,
          created_at: date,
          updated_at: Time.zone.now,
          agreement_type: "crown",
        )
      end
    end

    it "creates a non-crown MOU signature" do
      freeze_time do
        expect { task.invoke(user.email, organisation.name, date.iso8601, "non_crown") }
          .to change(MouSignature, :count).by(1)
                                          .and output(/Added MOU signature for User: A Person and Organisation: Government Digital Service signed at: 2020-01-01 00:00/).to_stdout

        expect(MouSignature.last).to have_attributes(
          user:,
          organisation:,
          created_at: date,
          updated_at: Time.zone.now,
          agreement_type: "non_crown",
        )
      end
    end
  end

  describe "mou_signatures:update_organisation" do
    subject(:task) do
      Rake::Task["mou_signatures:update_organisation"]
    end

    let(:user) { create :user }
    let(:current_organisation) { create :organisation, slug: "government-digital-service" }
    let(:target_organisation) { create :organisation, slug: "cabinet-office" }
    let(:mou_signature) { create :mou_signature, user:, organisation: current_organisation }

    it "aborts when the user is not found" do
      expect { task.invoke("john.doe@digital.cabinet-office.gov.uk", current_organisation.name, target_organisation.name) }
        .to output(/User with email address: john.doe@digital.cabinet-office.gov.uk not found/)
              .to_stderr
              .and raise_error(SystemExit) { |e| expect(e).not_to be_success }
    end

    it "aborts when the current organisation is not found" do
      expect { task.invoke(user.email, "GDS", target_organisation.name) }
        .to output(/Organisation with name: GDS not found/)
              .to_stderr
              .and raise_error(SystemExit) { |e| expect(e).not_to be_success }
    end

    it "aborts when the target organisation is not found" do
      expect { task.invoke(user.email, current_organisation.name, "GDS") }
        .to output(/Organisation with name: GDS not found/)
              .to_stderr
              .and raise_error(SystemExit) { |e| expect(e).not_to be_success }
    end

    it "aborts when an MOU signature is not found for the user and organisation" do
      expect { task.invoke(user.email, target_organisation.name, current_organisation.name) }
        .to output(/MOU signature for User:/)
              .to_stderr
              .and raise_error(SystemExit) { |e| expect(e).not_to be_success }
    end

    it "updates the organisation for an MOU" do
      mou_signature
      expect { task.invoke(user.email, current_organisation.name, target_organisation.name) }
        .to change { mou_signature.reload.organisation }.to(target_organisation)
        .and output(/Updated MOU signature/)
              .to_stdout
    end
  end

  describe "mou_signatures:revoke_user_signature" do
    subject(:task) do
      Rake::Task["mou_signatures:revoke_user_signature"]
    end

    let(:user) { create :user }
    let(:target_organisation) { create :organisation, slug: "cabinet-office" }
    let(:mou_signature) { create :mou_signature, user:, organisation: target_organisation }

    it "aborts when the user is not found" do
      expect { task.invoke("not-found@example.org", target_organisation.name) }
        .to output(/User with email address: not-found@example.org not found/)
              .to_stderr
              .and raise_error(SystemExit) { |e| expect(e).not_to be_success }
    end

    it "aborts when the organisation is not found" do
      expect { task.invoke(user.email, "not-real") }
        .to output(/Organisation with name: not-real not found/)
              .to_stderr
              .and raise_error(SystemExit) { |e| expect(e).not_to be_success }
    end

    it "aborts when an MOU signature is not found for the user and organisation" do
      expect { task.invoke(user.email, target_organisation.name) }
        .to output(/User: .* has not signed the MOU for organisation: /)
              .to_stderr
              .and raise_error(SystemExit) { |e| expect(e).not_to be_success }
    end

    it "removes the MOU signature for an organisation when it is found" do
      create :mou_signature, user:, organisation: target_organisation

      expect { task.invoke(user.email, target_organisation.name) }
        .to change(MouSignature, :count).by(-1)
        .and output(/Signature of user: .* on MOU for organisation: .* has been revoked/)
            .to_stdout
    end
  end
end
