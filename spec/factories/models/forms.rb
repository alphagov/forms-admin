FactoryBot.define do
  factory :form, class: "Form" do
    sequence(:name) { |n| "Form #{n}" }
    sequence(:form_slug) { |n| "form-#{n}" }
    submission_email { Faker::Internet.email(domain: "example.gov.uk") }
    privacy_policy_url { Faker::Internet.url(host: "gov.uk") }
    org { "test-org" }
    live_at { nil }
    missing_sections { nil }
    support_email { nil }
    support_phone { nil }
    support_url { nil }
    support_url_text { nil }
    what_happens_next_text { nil }
    question_section_completed { false }
    declaration_section_completed { false }

    trait :new_form do
      submission_email { "" }
      privacy_policy_url { "" }
      pages { [] }
    end

    trait :ready_for_live do
      support_email { Faker::Internet.email(domain: "example.gov.uk") }
      what_happens_next_text { "We usually respond to applications within 10 working days." }
      question_section_completed { true }
      declaration_section_completed { true }
    end

    trait :live do
      live_at { Time.zone.now }
      support_email { Faker::Internet.email(domain: "example.gov.uk") }
      what_happens_next_text { "We usually respond to applications within 10 working days." }
      question_section_completed { true }
      declaration_section_completed { true }
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
  end
end
