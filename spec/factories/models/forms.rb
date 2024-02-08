FactoryBot.define do
  factory :form, class: :Form do
    sequence(:name) { |n| "Form #{n}" }
    sequence(:form_slug) { |n| "form-#{n}" }
    has_draft_version { true }
    has_live_version { false }
    submission_email { Faker::Internet.email(domain: "example.gov.uk") }
    privacy_policy_url { Faker::Internet.url(host: "gov.uk") }
    organisation_id { 1 }
    live_at { nil }
    support_email { nil }
    support_phone { nil }
    support_url { nil }
    support_url_text { nil }
    what_happens_next_markdown { nil }
    declaration_text { nil }
    question_section_completed { false }
    declaration_section_completed { false }
    has_routing_errors { false }
    creator_id { nil }
    ready_for_live { false }
    incomplete_tasks { %i[missing_pages missing_privacy_policy_url missing_contact_details missing_what_happens_next] }
    state { :draft }

    transient do
      statuses { { declaration_status: "not_started", make_live_status: "cannot_start", name_status: "completed", pages_status: "not_started", privacy_policy_status: "not_started", support_contact_details_status: "not_started", what_happens_next_status: "not_started" } }
    end
    task_statuses { OpenStruct.new(attributes: statuses) }

    trait :new_form do
      submission_email { "" }
      privacy_policy_url { "" }
      state { :draft }
    end

    trait :with_id do
      sequence(:id) { |n| n }
    end

    trait :ready_for_live do
      with_pages
      support_email { Faker::Internet.email(domain: "example.gov.uk") }
      what_happens_next_markdown { "We usually respond to applications within 10 working days." }
      question_section_completed { true }
      declaration_section_completed { true }
      ready_for_live { true }
      incomplete_tasks { [] }
      transient do
        statuses { { declaration_status: "completed", make_live_status: "not_started", name_status: "completed", pages_status: "completed", privacy_policy_status: "completed", support_contact_details_status: "completed", what_happens_next_status: "completed" } }
      end
      task_statuses { OpenStruct.new(attributes: statuses) }
    end

    trait :live do
      ready_for_live
      live_at { Time.zone.now }
      has_draft_version { false }
      has_live_version { true }
      state { :live }
    end

    trait :with_active_resource do
      task_statuses { statuses }
    end

    trait :with_pages do
      transient do
        pages_count { 5 }
      end

      pages do
        Array.new(pages_count) { association(:page) }
      end

      question_section_completed { true }
    end

    trait :with_support do
      support_email { Faker::Internet.email(domain: "example.gov.uk") }
      support_phone { Faker::Lorem.paragraph(sentence_count: 2, supplemental: true, random_sentences_to_add: 4) }
      support_url { Faker::Internet.url(host: "gov.uk") }
      support_url_text { Faker::Lorem.sentence(word_count: 1, random_words_to_add: 4) }
    end

    trait :ready_for_routing do
      transient do
        pages_count { 5 }
      end

      pages do
        Array.new(pages_count) { association(:page, :with_selections_settings) }
      end
    end
  end
end
