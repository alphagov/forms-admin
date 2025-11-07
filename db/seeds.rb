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
                                terms_agreed_at: Time.zone.now,
                                research_contact_status: :consented,
                                user_research_opted_in_at: Time.zone.now })

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
    research_contact_status: :consented,
    user_research_opted_in_at: Time.zone.now,
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
    research_contact_status: :consented,
    user_research_opted_in_at: Time.utc(2024, 4, 22, 9, 30),
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
  test_group = Group.create! name: "Test Group", organisation: gds, creator: default_user
  Group.create! name: "Ministry of Tests forms", organisation: mot_org
  Group.create! name: "Ministry of Tests forms - secret!", organisation: mot_org, creator: mot_user
  welsh_group = Group.create! name: "Welsh enabled", organisation: gds, welsh_enabled: true

  Membership.create! user: default_user, group: end_to_end_group, added_by: default_user, role: :group_admin

  submission_email = ENV["EMAIL"] || `git config --get user.email`.strip

  all_question_types_form = Form.create!(
    name: "All question types form",
    pages: [
      Page.create(
        question_text: "Single line of text",
        answer_type: "text",
        answer_settings: {
          input_type: "single_line",
        },
        is_optional: false,
      ),
      Page.create(
        question_text: "Number",
        answer_type: "number",
        is_optional: false,
      ),
      Page.create(
        question_text: "Address",
        answer_type: "address",
        answer_settings: {
          input_type: {
            international_address: false,
            uk_address: true,
          },
        },
        is_optional: false,
      ),
      Page.create(
        question_text: "Email address",
        answer_type: "email",
        is_optional: false,
      ),
      Page.create(
        question_text: "Todays Date",
        answer_type: "date",
        answer_settings: {
          input_type: "other_date",
        },
        is_optional: false,
      ),
      Page.create(
        question_text: "National Insurance number",
        answer_type: "national_insurance_number",
        is_optional: false,
      ),
      Page.create(
        question_text: "Phone number",
        answer_type: "phone_number",
        is_optional: false,
      ),
      Page.create(
        question_text: "Selection from a list of options",
        answer_type: "selection",
        answer_settings: {
          "only_one_option": "0", # TODO: investigate why we set this to "0"
          "selection_options": [
            { "name": "Option 1" },
            { "name": "Option 2" },
            { "name": "Option 3" },
          ],
        },
        is_optional: true, # Include an option for 'None of the above'
      ),
      Page.create(
        question_text: "Multiple lines of text",
        answer_type: "text",
        answer_settings: {
          input_type: "long_text",
        },
        is_optional: true,
      ),
    ],
    question_section_completed: true,
    declaration_text: "",
    declaration_section_completed: true,
    privacy_policy_url: "https://www.gov.uk/help/privacy-notice",
    submission_email:,
    support_email: "your.email+fakedata84701@gmail.com.gov.uk",
    support_phone: "08000800",
    what_happens_next_markdown: "Test",
    share_preview_completed: true,
  )
  all_question_types_form.make_live!

  e2e_s3_forms = Form.create!(
    name: "s3 submission test form",
    pages: [
      Page.create(
        question_text: "Single line of text",
        answer_type: "text",
        answer_settings: {
          input_type: "single_line",
        },
        is_optional: false,
      ),
    ],
    question_section_completed: true,
    declaration_text: "",
    declaration_section_completed: true,
    privacy_policy_url: "https://www.gov.uk/help/privacy-notice",
    submission_email:,
    support_email: "your.email+fakedata84701@gmail.com.gov.uk",
    support_phone: "08000800",
    what_happens_next_markdown: "Test",
    share_preview_completed: true,
    submission_type: "s3",
    s3_bucket_region: "eu-west-2",
  )
  e2e_s3_forms.make_live!

  branch_route_form = Form.create!(
    name: "Branch route form",
    pages: [
      Page.create(
        question_text: "Are you eligible to submit this form?",
        answer_type: "selection",
        answer_settings: {
          only_one_option: "true",
          selection_options: [
            { "name": "Yes" },
            { "name": "No" },
          ],
        },
        is_optional: false,
      ),
      Page.create(
        question_text: "How many times have you filled out this form?",
        answer_type: "selection",
        answer_settings: {
          only_one_option: "true",
          selection_options: [
            { "name": "Once" },
            { "name": "More than once" },
          ],
        },
        is_optional: false,
      ),
      Page.create(
        question_text: "What’s your name?",
        answer_type: "name",
        answer_settings: {
          input_type: "full_name",
          title_needed: false,
        },
        is_optional: false,
        is_repeatable: false,
      ),
      Page.create(
        question_text: "What’s your email address?",
        answer_type: "email",
        is_optional: false,
        is_repeatable: false,
      ),
      Page.create(
        question_text: "What was the reference of your previous submission?",
        answer_type: "text",
        answer_settings: {
          input_type: "single_line",
        },
        is_optional: false,
        is_repeatable: false,
      ),
      Page.create(
        question_text: "What’s your answer?",
        answer_type: "text",
        answer_settings: {
          input_type: "single_line",
        },
        is_optional: false,
        is_repeatable: false,
      ),
    ],
    question_section_completed: true,
    declaration_text: "",
    declaration_section_completed: true,
    privacy_policy_url: "https://www.gov.uk/help/privacy-notice",
    submission_email:,
    support_email: "your.email+fakedata84701@gmail.com.gov.uk",
    support_phone: "08000800",
    what_happens_next_markdown: "Test",
    share_preview_completed: true,
  )
  Condition.create!(
    check_page: branch_route_form.pages.second,
    routing_page: branch_route_form.pages.second,
    goto_page: branch_route_form.pages.fifth,
    answer_value: "More than once",
  )
  Condition.create!(
    check_page: branch_route_form.pages.second,
    routing_page: branch_route_form.pages.fourth,
    goto_page: branch_route_form.pages.last,
    answer_value: nil,
  )
  Condition.create!(
    check_page: branch_route_form.pages.first,
    routing_page: branch_route_form.pages.first,
    goto_page: nil,
    answer_value: "No",
    exit_page_heading: "You are not eligible to submit this form",
    exit_page_markdown: <<~MARKDOWN,
      To complete this form you must:

        - Be over 16
        - Confirmed that you are eligible to submit this form
    MARKDOWN
  )
  branch_route_form.reload.make_live!

  welsh_form = Form.create!(
    name: "A Welsh form",
    pages: [
      Page.create(
        question_text: "What’s your name?",
        answer_type: "name",
        hint_text: "Enter your name as it appears on your licence.",
        answer_settings: {
          input_type: "full_name",
          title_needed: false,
        },
        is_optional: false,
        is_repeatable: false,
      ),
      Page.create(
        question_text: "What’s your email address?",
        answer_type: "email",
        is_optional: false,
        is_repeatable: false,
        page_heading: "Email",
        guidance_markdown: "We'll use your email to:\n\n- contact you if there are any issues with your submission\n\n- send you your digital licence",
      ),
      Page.create(
        question_text: "What was the reference of your previous submission?",
        answer_type: "text",
        answer_settings: {
          input_type: "single_line",
        },
        is_optional: false,
        is_repeatable: false,
      ),
      Page.create(
        question_text: "What’s your answer?",
        answer_type: "text",
        answer_settings: {
          input_type: "single_line",
        },
        is_optional: false,
        is_repeatable: false,
      ),
    ],
    question_section_completed: true,
    declaration_text: "",
    declaration_section_completed: true,
    privacy_policy_url: "https://www.gov.uk/help/privacy-notice",
    submission_email:,
    support_email: "your.email+fakedata84701@gmail.com.gov.uk",
    support_phone: "08000800",
    what_happens_next_markdown: "Test",
    share_preview_completed: true,
  )

  # add forms to groups
  GroupForm.create! group: end_to_end_group, form_id: all_question_types_form.id # All question types form
  GroupForm.create! group: end_to_end_group, form_id: e2e_s3_forms.id # s3 submission test form
  GroupForm.create! group: test_group, form_id: branch_route_form.id # Branch routing form
  GroupForm.create! group: welsh_group, form_id: welsh_form.id # Welsh form
end
