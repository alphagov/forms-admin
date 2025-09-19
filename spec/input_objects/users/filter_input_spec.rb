require "rails_helper"

RSpec.describe Users::FilterInput, type: :model do
  describe "#has_filters?" do
    context "when the name filter is set" do
      subject(:input) { described_class.new(name: "foo") }

      it "returns true" do
        expect(input.has_filters?).to be true
      end
    end

    context "when the email filter is set" do
      subject(:input) { described_class.new(email: "foo") }

      it "returns true" do
        expect(input.has_filters?).to be true
      end
    end

    context "when the organisation_id filter is set" do
      subject(:input) { described_class.new(organisation_id: 1) }

      it "returns true" do
        expect(input.has_filters?).to be true
      end
    end

    context "when the role filter is set" do
      subject(:input) { described_class.new(role: "standard") }

      it "returns true" do
        expect(input.has_filters?).to be true
      end
    end

    context "when the has_access filter is set" do
      subject(:input) { described_class.new(has_access: true) }

      it "returns true" do
        expect(input.has_filters?).to be true
      end
    end

    context "when no filters are set" do
      subject(:input) { described_class.new }

      it "returns false" do
        expect(input.has_filters?).to be false
      end
    end
  end

  describe "#organisation_options" do
    before do
      create(:organisation, :with_org_admin, slug: "org-1")
      create(:organisation, :with_org_admin, slug: "org-2")
      create(:organisation, slug: "org-3")
    end

    it "returns all organisations with users and an option for all organisations" do
      options = described_class.new.organisation_options
      expect(options.size).to eq 3
      expect(options[0]).to eq OpenStruct.new(name_with_abbreviation: "All organisations", id: "all")
    end
  end

  describe "#access_options" do
    it "returns the correct options" do
      expect(described_class.new.access_options).to eq([
        OpenStruct.new(label: I18n.t("users.has_access.any")),
        OpenStruct.new(label: I18n.t("users.has_access.true.name"), value: "true", description: I18n.t("users.has_access.true.description")),
        OpenStruct.new(label: I18n.t("users.has_access.false.name"), value: "false", description: I18n.t("users.has_access.false.description")),
      ])
    end
  end

  describe "#role_options" do
    it "returns the correct options" do
      expect(described_class.new.role_options).to eq(
        [
          OpenStruct.new(label: I18n.t("users.roles.all")),
          OpenStruct.new(label: I18n.t("users.roles.super_admin.name"), value: "super_admin", description: I18n.t("users.roles.super_admin.description")),
          OpenStruct.new(label: I18n.t("users.roles.organisation_admin.name"), value: "organisation_admin", description: I18n.t("users.roles.organisation_admin.description")),
          OpenStruct.new(label: I18n.t("users.roles.standard.name"), value: "standard", description: I18n.t("users.roles.standard.description")),
        ],
      )
    end
  end
end
