# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

if (HostingEnvironment.local_development? || HostingEnvironment.review?) && User.none?

  gds = Organisation.find_or_create_by!(
    govuk_content_id: "af07d5a5-df63-4ddc-9383-6a666845ebe9",
    slug: "government-digital-service",
    name: "Government Digital Service",
    abbreviation: "GDS",
  )

  # Create default super-admin
  default_user = User.create!({ email: "example@example.com",
                                organisation_slug: "government-digital-service",
                                organisation_content_id: "af07d5a5-df63-4ddc-9383-6a666845ebe9",
                                organisation: gds,
                                name: "A User",
                                role: :super_admin,
                                uid: "123456",
                                provider: :mock_gds_sso,
                                terms_agreed_at: Time.zone.now })

  MouSignature.create! user: default_user, organisation: gds

  # create extra organisations
  test_org = Organisation.create! slug: "test-org", name: "Test Org", abbreviation: "TO"
  mot_org = Organisation.create! slug: "ministry-of-tests", name: "Ministry of Tests", abbreviation: "MOT"
  Organisation.create! slug: "department-for-testing", name: "Department for Testing", abbreviation: "DfT"
  Organisation.create! slug: "closed-org", name: "Closed Org", abbreviation: "CO", closed: true

  # create extra standard users
  User.create!(
    email: "phil@example.gov.uk",
    name: "Phil Mein",
    role: :standard,
    organisation: test_org,
    provider: :seed,
  )
  mot_user = User.create!(
    email: "subo@example.gov.uk",
    name: "Subo Mitt",
    role: :standard,
    organisation: mot_org,
    provider: :seed,
  )
  User.create!(
    email: "otto@example.gov.uk",
    name: "Otto Komplit",
    role: :standard,
    organisation: test_org,
    provider: :seed,
  )

  # create extra super admins
  User.create!(
    email: "craig@example.gov.uk",
    name: "Craig",
    role: :super_admin,
    organisation: gds,
    created_at: Time.utc(2022, 3, 3, 9),
    last_signed_in_at: Time.utc(2022, 3, 3, 9),
    terms_agreed_at: Time.utc(2022, 3, 3, 9),
    provider: :seed,
  )
  User.create!(
    email: "bey@example.gov.uk",
    name: "Bey",
    role: :super_admin,
    organisation: gds,
    created_at: Time.utc(2023, 3, 11, 6, 26),
    last_signed_in_at: Time.utc(2023, 3, 11, 6, 26),
    terms_agreed_at: Time.utc(2023, 3, 11, 6, 26),
    provider: :seed,
  )
  User.create!(
    email: "taylor@example.gov.uk",
    name: "Taylor",
    role: :super_admin,
    organisation: gds,
    created_at: Time.utc(2024, 4, 22, 9, 30),
    last_signed_in_at: Time.utc(2024, 4, 22, 9, 30),
    terms_agreed_at: Time.utc(2024, 4, 22, 9, 30),
    provider: :seed,
  )

  # while we're using Signon it is possible to have users who aren't linked to
  # the same organisation as in Signon, or who have an organisation that isn't
  # in the organisation table
  User.create!(
    email: "bakbert@example.gov.uk",
    name: "Bakber Tan",
    organisation_slug: test_org.slug,
    organisation_content_id: test_org.govuk_content_id,
    provider: :seed,
  )
  User.create!(
    email: "ckboxes@example.gov.uk",
    name: "Che K Boxes",
    organisation_slug: "unknown-org",
    organisation_content_id: "fb48187d-6a62-42e1-ab8e-cbb4205075ad",
    provider: :seed,
  )

  # create a user who hasn't been assigned to an organisation yet
  User.create!(
    email: "lez.philmore@example.gov.uk",
    name: "Lez Philmore",
    provider: :seed,
  )

  # create some standard users without name or organisation
  User.create!(email: "kezz.strel101@example.gov.uk", role: :standard, provider: :seed)
  User.create!(email: "lauramipsum@example.gov.uk", role: :standard, provider: :seed)
  User.create!(email: "chidi.anagonye@example.gov.uk", role: :standard, provider: :seed)

  # create some test groups
  end_to_end_group = Group.create! name: "End to end tests", organisation: gds, status: :active
  Group.create! name: "Test Group", organisation: gds, creator: default_user
  Group.create! name: "Ministry of Tests forms", organisation: mot_org
  Group.create! name: "Ministry of Tests forms - secret!", organisation: mot_org, creator: mot_user
  branch_routing_enabled_group = Group.create! name: "Branching enabled", organisation: gds, branch_routing_enabled: true

  Membership.create! user: default_user, group: end_to_end_group, added_by: default_user, role: :group_admin

  # add forms to groups (assumes database seed is being used for forms-api)
  GroupForm.create! group: end_to_end_group, form_id: 1 # All question types form
  GroupForm.create! group: end_to_end_group, form_id: 2 # s3 submission test form
  GroupForm.create! group: branch_routing_enabled_group, form_id: 3 # Branch route form
end
