require "gds-sso/lint/user_spec"
require "rails_helper"

describe User, type: :model do
  subject(:user) { described_class.new }

  it "validates" do
    expect(user.valid?).to be true
  end

  describe "versioning", versioning: true do
    it "enables paper trail" do
      expect(user).to be_versioned
    end
  end

  describe "role enum" do
    it "returns a list of roles" do
      expect(described_class.roles.keys).to eq(%w[super_admin editor trial])
      expect(described_class.roles.values).to eq(%w[super_admin editor trial])
    end
  end

  it_behaves_like "a gds-sso user class"

  describe "role" do
    it "is invalid if blank" do
      user.role = nil

      expect(user.valid?).to be false
    end
  end

  describe "organisation_id" do
    it "is allowed to be nil" do
      user.organisation_id = nil

      expect(user.valid?).to be true
    end
  end

  context "when updating organisation" do
    it "is valid to leave organisation unset" do
      user = create :user, :with_no_org
      user.organisation_id = nil
      expect(user.valid?).to be true
    end

    it "is not valid to unset organisation if it is already set" do
      user = create(:user, organisation: create(:organisation, slug: "test-org"))
      user.organisation_id = nil
      expect(user.valid?).to be false
    end

    it "is not valid to leave organisation unset if changing role to editor" do
      user = create :user, :with_no_org, role: :trial
      user.role = :editor
      expect(user.valid?).to be false
    end
  end

  describe ".find_for_auth" do
    let!(:user) do
      create :user, provider: "test", uid: "123456", name: "Test User", email: "test@example.com"
    end

    it "finds a user by uid" do
      expect(described_class.find_for_auth(provider: "test", uid: "123456"))
        .to eq user
    end

    it "avoids uid collisions" do
      expect(described_class.find_for_auth(provider: "other", uid: "123456"))
        .not_to eq user
    end

    it "finds a user by email address if no user with uid is found" do
      expect(described_class.find_for_auth(uid: "111111", email: "test@example.com"))
        .to eq user

      expect(user.reload.uid).to eq "111111"
    end

    it "creates a user if one does not already exist" do
      allow(described_class).to receive(:create!)

      described_class.find_for_auth(
        provider: "test",
        uid: "9999",
        email: "fake@example.com",
        name: "Fake Name",
      )

      expect(described_class).to have_received(:create!)
    end

    it "updates any user attributes that have changed" do
      described_class.find_for_auth(
        provider: "test",
        uid: "123456",
        name: "New Name",
      )

      expect(user.reload.name).to eq "New Name"
    end

    it "logs attributes that will be updated" do
      allow(EventLogger).to receive(:log)

      described_class.find_for_auth(
        provider: "test",
        uid: "111111",
        name: "Test A. User",
        email: "test@example.com",
      )

      expect(EventLogger).to have_received(:log).with(
        {
          "event": "auth",
          "user_id": user.id,
          "user_changes": {
            uid: %w[123456 111111],
            name: ["Test User", "Test A. User"],
          },
        },
      )
    end
  end

  context "when changing role" do
    described_class.roles.reject { |role| role == "trial" }.each do |_role_name, role_value|
      it "updates user's forms' org when changing role from trial to #{role_value}" do
        user = create(:user, role: :trial)

        expect(Form).to receive(:update_organisation_for_creator).with(user.id, user.organisation.id)

        user.role = role_value
        user.save!
        user.update_user_forms
      end

      it "does not update user's forms' org when changing role from #{role_value} to editor" do
        user = create :user, role: role_value

        expect(Form).not_to receive(:update_organisation_for_creator).with(user.id, user.organisation.id)

        user.role = :editor
        user.save!
        user.update_user_forms
      end
    end
  end

  it "defaults to the trial role" do
    user = described_class.new
    expect(user.role).to eq("trial")
  end

  describe "versioning" do
    with_versioning do
      it "creates a version when role is changed" do
        user = create :user
        expect {
          user.update!(role: :editor)
        }.to change { user.versions.size }.by(1)
      end

      it "creates a version when organisation_id is changed" do
        user = create :user, :with_no_org
        expect {
          org = create :organisation
          user.update!(organisation: org)
        }.to change { user.versions.size }.by(1)
      end

      it "creates a version when has_access is changed" do
        user = create :user
        expect {
          user.update!(has_access: false)
        }.to change { user.versions.size }.by(1)
      end

      it "does not create a version when other attributes are changed" do
        user = create :user
        expect {
          user.update(name: "new_name", email: "new_email@example.gov.uk", uid: Faker::Internet.uuid, provider: "new_provider")
        }.not_to(change { user.versions.size })
      end
    end
  end

  context "when updating name" do
    it "is valid to leave name unset" do
      user = create :user, :with_no_name
      user.name = nil
      expect(user.valid?).to be true
    end

    it "is not valid to unset name if it is already set" do
      user = create :user, name: "Test User"
      user.name = nil
      expect(user.valid?).to be false
    end

    it "is not valid to leave name unset if changing role to editor" do
      user = create :user, :with_no_name, role: :trial
      user.role = :editor
      expect(user.valid?).to be false
    end

    it "is not valid to leave name unset if changing role to super admin" do
      user = create :user, :with_no_name, role: :trial
      user.role = :super_admin
      expect(user.valid?).to be false
    end
  end
end
