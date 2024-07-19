require "gds-sso/lint/user_spec"
require "rails_helper"

describe User, type: :model do
  subject(:user) { described_class.new }

  let(:organisation) { create :organisation }

  describe "validations" do
    it "validates" do
      expect(user).to be_valid
    end

    describe "role" do
      it "is invalid if blank" do
        user.role = nil

        expect(user).to be_invalid
      end
    end

    describe "organisation_id" do
      it "is allowed to be nil" do
        user.organisation_id = nil

        expect(user).to be_valid
      end
    end

    describe "email" do
      it "does not allow users to be created with the same email with different case" do
        create(:user, email: "foo.bar@email.gov.uk")

        expect {
          described_class.create!(name: Faker.name, email: "Foo.Bar@email.gov.uk", role: :editor, organisation_id: organisation.id)
        }.to raise_error ActiveRecord::RecordInvalid, /Email has already been taken/
      end
    end

    context "when updating organisation" do
      let(:user) { create :user, :with_no_org, role: :trial }

      it "is valid to leave organisation unset" do
        user.organisation_id = nil
        expect(user).to be_valid
      end

      it "is not valid to unset organisation if it is already set" do
        user.organisation = create(:organisation, slug: "test-org")
        user.save!

        user.organisation_id = nil
        expect(user).to be_invalid
      end

      it "is not valid to leave organisation unset if changing role to organisation admin" do
        user.role = :organisation_admin
        expect(user).to be_invalid
      end
    end

    context "when updating name" do
      let(:user) { create :user, :with_no_name, role: :trial }

      context "when user has been created with a trial account" do
        it "is valid to leave name unset" do
          user.name = nil
          expect(user).to be_valid
        end
      end

      context "when user somehow has no name" do
        let(:user) do
          user = build(:editor_user, :with_no_name)
          user.save!(validate: false)
          user
        end

        it "is valid to leave name unset" do
          user.name = nil
          expect(user).to be_valid
        end
      end

      it "is not valid to unset name if it is already set" do
        user.update!(name: "Test User")
        user.name = nil
        expect(user).to be_invalid
      end
    end

    context "when the user belongs to an organisation that doesn't have a signed mou" do
      let(:organisation) { create(:organisation) }
      let(:user) { create(:user, organisation:) }

      it "is not valid for a user's role to be organisation_admin" do
        user.role = :organisation_admin
        expect(user).to be_invalid
      end

      it "is valid for a user's role to be editor" do
        user.role = :editor
        expect(user).to be_valid
      end
    end

    context "when the user belongs to an organisation that does have a signed mou" do
      let(:organisation) { create(:organisation, :with_signed_mou) }
      let(:user) { create(:user, organisation:) }

      it "is valid for a user's role to be organisation_admin" do
        user.role = :organisation_admin
        expect(user).to be_valid
      end
    end
  end

  describe "versioning", :versioning do
    it "enables paper trail" do
      expect(user).to be_versioned
    end
  end

  describe "role enum" do
    it "returns a list of roles" do
      expect(described_class.roles.keys).to eq(%w[super_admin organisation_admin editor trial standard])
      expect(described_class.roles.values).to eq(%w[super_admin organisation_admin editor trial standard])
    end

    describe "#standard_user?" do
      it "returns true if the user has the editor role" do
        user.role = :editor
        expect(user).to be_standard_user
      end

      it "returns true if the user has the trial role" do
        user.role = :trial
        expect(user).to be_standard_user
      end

      it "returns true if the user has the standard role" do
        user.role = :standard
        expect(user).to be_standard_user
      end
    end
  end

  it_behaves_like "a gds-sso user class"

  describe "associations" do
    it "destroys associated memberships" do
      user = create(:user)
      group = create(:group)

      membership = create(:membership, user:, group:)
      user.destroy!

      expect { membership.reload }.to raise_error(ActiveRecord::RecordNotFound)
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
      expect(described_class.find_for_auth(provider: "other", uid: "123456", email: "someone@example.com"))
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
      allow(Rails.logger).to receive(:info)

      described_class.find_for_auth(
        provider: "test",
        uid: "111111",
        name: "Test A. User",
        email: "test@example.com",
      )

      expect(Rails.logger).to have_received(:info).with("User attributes updated upon authorisation", {
        "user_changes": {
          uid: %w[123456 111111],
          name: ["Test User", "Test A. User"],
        },
      })
    end
  end

  it "defaults to the trial role" do
    user = described_class.new
    expect(user.role).to eq("trial")
  end

  describe "#given_organisation?" do
    it "returns true when organisation_id is set" do
      user = create(:user, :with_no_org)
      user.update!(organisation: build(:organisation))
      expect(user).to be_given_organisation
    end

    it "returns false when organisation_id is not set" do
      user = create(:user, :with_no_org)
      expect(user).not_to be_given_organisation
    end

    it "returns false when organisation_id is set to nil" do
      user = create(:user, :with_trial_role, :with_no_org)
      user.update!(organisation: nil)
      expect(user).not_to be_given_organisation
    end

    it "returns false when user had an organisation" do
      user = create(:user)
      user.update!(organisation: build(:organisation))
      expect(user).not_to be_given_organisation
    end
  end

  describe "#is_organisations_admin?" do
    context "when the user does not have the organisation admin role" do
      it "returns false" do
        user = create(:user)
        expect(user.is_organisations_admin?(user.organisation)).to be(false)
      end
    end

    context "when the user has the organisation admin role" do
      context "and the user's organisation is the same as given" do
        it "returns true" do
          user = create(:organisation_admin_user)
          expect(user.is_organisations_admin?(user.organisation)).to be(true)
        end
      end

      context "and the user's organisation is not the same as given" do
        it "returns false" do
          user = create(:organisation_admin_user)
          other_org = build(:organisation, id: 2)

          expect(user.is_organisations_admin?(other_org)).to be(false)
        end
      end
    end
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

  describe "creation callbacks" do
    it "allow access for users with an unrestricted email domain" do
      user = create(:user)

      expect(user.organisation_restricted_access?).to be(false)
      expect(user.has_access).to be(true)
    end

    it "allow access for users without an email address" do
      user = create(:user, email: nil)

      expect(user.organisation_restricted_access?).to be(false)
      expect(user.has_access).to be(true)
    end

    User::EMAIL_DOMAIN_DENYLIST.each do |email_domain|
      it "deny access for users with a restricted email domain" do
        user = create(:user, email: "test@#{email_domain}")

        expect(user.organisation_restricted_access?).to be(true)
        expect(user.has_access).to be(false)
      end
    end
  end

  describe "is_group_admin?" do
    let(:user) { create(:user, organisation:) }
    let(:organisation) { create(:organisation, slug: "org") }
    let(:group) { create(:group, organisation:) }

    it "returns falsey when user is not in group" do
      expect(user).not_to be_is_group_admin(group)
    end

    it "returns falsey when a user is an editor of the group" do
      create(:membership, user:, group:, role: :editor)
      expect(user).not_to be_is_group_admin(group)
    end

    it "returns true when user is a group admin of the group" do
      create(:membership, user:, group:, role: :group_admin)
      expect(user.is_group_admin?(group)).to be(true)
    end
  end

  describe "#current_org_has_mou?" do
    let(:user) { create(:user, organisation:) }

    context "when current org has a signed mou" do
      let(:organisation) { create(:organisation, :with_signed_mou) }

      it "returns true" do
        expect(user.current_org_has_mou?).to be(true)
      end
    end

    context "when current org does not have a signed mou" do
      let(:organisation) { create(:organisation) }

      it "returns false" do
        expect(user.current_org_has_mou?).to be(false)
      end
    end

    context "when the user does not have an organisation" do
      let(:organisation) { nil }

      it "returns false" do
        expect(user.current_org_has_mou?).to be(false)
      end
    end
  end

  describe "#collect_analytics?" do
    before do
      allow(Settings).to receive(:analytics_enabled).and_return(analytics_enabled)
    end

    context "when the analytics settings flag is off" do
      let(:analytics_enabled) { false }

      context "when the user is a super admin" do
        let(:user) { create :super_admin_user }

        it "returns false" do
          expect(user.collect_analytics?).to be(false)
        end
      end

      context "when the user is not a super admin" do
        let(:user) { create :editor_user }

        it "returns false" do
          expect(user.collect_analytics?).to be(false)
        end
      end
    end

    context "when the analytics settings flag is on" do
      let(:analytics_enabled) { true }

      context "when the user is a super admin" do
        let(:user) { create :super_admin_user }

        it "returns false" do
          expect(user.collect_analytics?).to be(false)
        end
      end

      context "when the user is not a super admin" do
        let(:user) { create :editor_user }

        it "returns true" do
          expect(user.collect_analytics?).to be(true)
        end
      end
    end
  end
end
