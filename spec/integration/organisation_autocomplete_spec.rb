require "rails_helper"

RSpec.describe "Selecting an organisation using accessible autocomplete", type: :feature do
  before do
    create :organisation, slug: "department-for-testing", name: "Department for Testing", abbreviation: "DfT"
    create :organisation, slug: "ministry-of-tests", name: "Ministry of Tests", abbreviation: "MOT"
  end

  context "when editing a user" do
    before do
      login_as_super_admin_user

      user = create :user

      visit edit_user_path(user)
    end

    it "autocompletes the organisation" do
      organisation_field = find_field "Organisation"
      organisation_field.fill_in with: "tests\n"
      expect(organisation_field.value).to start_with "Ministry of Tests"
    end

    it "autocompletes the organisation by abbreviation" do
      organisation_field = find_field "Organisation"
      organisation_field.fill_in with: "DfT\n"
      expect(organisation_field.value).to start_with "Department for Testing"
    end
  end

  context "when choosing an organisation to view its forms" do
    before do
      login_as_super_admin_user

      create :user, organisation: Organisation.find_by(slug: "ministry-of-tests")
      create :user, organisation: Organisation.find_by(slug: "department-for-testing")

      visit root_path
    end

    it "autocompletes the organisation" do
      organisation_field = find_field "search[organisation_id]"
      organisation_field.fill_in with: "tests\n"
      expect(organisation_field.value).to start_with "Ministry of Tests"
    end

    it "autocompletes the organisation by abbreviation" do
      organisation_field = find_field "search[organisation_id]"
      organisation_field.fill_in with: "DfT\n"
      expect(organisation_field.value).to start_with "Department for Testing"
    end
  end
end
