require "rails_helper"

RSpec.describe Organisation, type: :model do
  it "is an error to create an organisation with an existing slug" do
    organisation = create(:organisation, slug: "duplicate-org")

    expect {
      described_class.create!(govuk_content_id: Faker::Internet.uuid, slug: organisation.slug, name: organisation.name)
    }.to raise_error ActiveRecord::RecordNotUnique
  end

  describe "factory" do
    it "does not create organisation if already exists" do
      existing_organisation = create(:organisation, slug: "duplicate-org")
      new_organisation = nil

      expect {
        new_organisation = create(:organisation, slug: "duplicate-org")
      }.not_to raise_error

      expect(new_organisation).to eq(existing_organisation)
    end
  end

  describe "versioning", versioning: true do
    it "enables paper trail" do
      expect(described_class.new).to be_versioned
    end
  end

  describe "associations" do
    describe "default_group" do
      it "does not have a default group by default" do
        expect(described_class.new.default_group).to be_nil
      end

      it "returns the default group when assigned" do
        organisation = described_class.create!(name: "test org", slug: "test-org")
        group = create(:group, organisation:)
        organisation.update!(default_group: group)

        expect(organisation.default_group).to eq(group)
      end
    end
  end

  describe "scopes" do
    describe ".with_users" do
      it "returns organisations with distinct users" do
        FactoryBot.create(:organisation, slug: "org_3")
        organisation2 = FactoryBot.create(:organisation, slug: "org_2")
        organisation1 = FactoryBot.create(:organisation, slug: "org_1")

        FactoryBot.create(:user, organisation: organisation1)
        FactoryBot.create(:user, organisation: organisation1)
        FactoryBot.create(:user, organisation: organisation2)

        organisations_with_users = described_class.with_users

        expect(organisations_with_users).to eq([organisation1, organisation2])
      end
    end

    describe ".not_closed" do
      it "returns organisations which are not closed" do
        organisation = create :organisation
        create :organisation, slug: "closed-org", closed: true

        expect(described_class.not_closed).to eq [organisation]
      end
    end
  end

  describe "#name_with_abbreviation" do
    it "uses abbreviation when it is not the same as name" do
      organisation = build :organisation, name: "An Organisation", abbreviation: "ABBR"
      expect(organisation.name_with_abbreviation).to eq "An Organisation (ABBR)"
    end

    it "does not use abbreviation when it is not present" do
      organisation = build :organisation, name: "An Organisation", abbreviation: "   "
      expect(organisation.name_with_abbreviation).to eq organisation.name
    end

    it "does not use abbreviation when it is present but the same as name" do
      organisation = build :organisation, name: "An Organisation", abbreviation: "An Organisation"
      expect(organisation.name_with_abbreviation).to eq organisation.name
    end
  end
end
