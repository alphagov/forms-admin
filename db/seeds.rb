# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

require "factory_bot"

if HostingEnvironment.local_development? && User.none?

  gds = Organisation.find_or_create_by!(govuk_content_id: "af07d5a5-df63-4ddc-9383-6a666845ebe9", slug: "government-digital-service", name: "Government Digital Service")

  # Create default super-admin
  User.create!({ email: "example@example.com",
                 organisation_slug: "government-digital-service",
                 organisation_content_id: "af07d5a5-df63-4ddc-9383-6a666845ebe9",
                 organisation: gds,
                 name: "A User",
                 role: :super_admin,
                 uid: "123456",
                 provider: :mock_gds_sso })

  # create extra organisations
  test_org = FactoryBot.create :organisation, slug: "test-org"
  FactoryBot.create :organisation, slug: "ministry-of-tests"
  FactoryBot.create :organisation, slug: "department-for-testing"

  # create extra editors
  FactoryBot.create_list :user, 3, organisation: test_org, role: :editor

  # create extra super admins
  FactoryBot.create_list :user, 3, organisation: gds, role: :super_admin

  # while we're using Signon it is possible to have users who aren't linked to
  # the same organisation as in Signon, or who have an organisation that isn't
  # in the organisation table
  FactoryBot.create :user, :with_unknown_org, organisation_slug: test_org.slug, organisation_content_id: test_org.govuk_content_id
  FactoryBot.create :user, :with_unknown_org

  # create a user who hasn't been assigned to an organisation yet
  FactoryBot.create :user, :with_no_org

  # create some trial users
  FactoryBot.create_list :user, 3, :with_trial_role
end
