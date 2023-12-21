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

  describe "scopes" do
    describe ".with_users" do
      it "returns organisations with distinct users" do
        organisation2 = FactoryBot.create(:organisation, slug: "org_2")
        organisation1 = FactoryBot.create(:organisation, slug: "org_1")

        FactoryBot.create(:user, organisation: organisation1)
        FactoryBot.create(:user, organisation: organisation1)
        FactoryBot.create(:user, organisation: organisation2)

        organisations_with_users = described_class.with_users

        expect(organisations_with_users.first).to eq(organisation1)
        expect(organisations_with_users.last).to eq(organisation2)
        expect(organisations_with_users.size).to eq(2)
      end
    end
  end
end
