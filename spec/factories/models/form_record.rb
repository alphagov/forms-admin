FactoryBot.define do
  factory :form_record, class: "Form" do
    sequence(:name) { |n| "Form #{n}" }
    sequence(:form_slug) { |n| "form-#{n}" }
    submission_email { Faker::Internet.email(domain: "example.gov.uk") }
    privacy_policy_url { Faker::Internet.url(host: "gov.uk") }
    support_email { nil }
    support_phone { nil }
    support_url { nil }
    support_url_text { nil }
    what_happens_next_markdown { nil }
    declaration_text { nil }
    question_section_completed { false }
    declaration_section_completed { false }
    state { :draft }
    payment_url { nil }
    external_id { nil }

    trait :new_form do
      submission_email { "" }
      privacy_policy_url { "" }
      pages { [] }
      state { :draft }
    end

    trait :with_pages do
      transient do
        pages_count { 5 }
      end

      pages do
        Array.new(pages_count) { association(:page, factory: :page_record) }
      end

      question_section_completed { true }
    end

    trait :with_text_page do
      pages do
        Array.new(1) { association(:page, factory: :page_record, answer_type: "text", answer_settings: { input_type: %w[single_line long_text].sample }) }
      end

      question_section_completed { true }
    end

    trait :ready_for_live do
      with_pages
      support_email { Faker::Internet.email(domain: "example.gov.uk") }
      what_happens_next_markdown { "We usually respond to applications within 10 working days." }
      question_section_completed { true }
      declaration_section_completed { true }
      share_preview_completed { true }
    end

    trait :live do
      ready_for_live
      after(:create, &:make_live!)
    end

    trait :archived do
      live
      after(:create, &:archive_live_form!)
    end

    trait :with_support do
      support_email { Faker::Internet.email(domain: "example.gov.uk") }
      support_phone { Faker::Lorem.paragraph(sentence_count: 2, supplemental: true, random_sentences_to_add: 4) }
      support_url { Faker::Internet.url(host: "gov.uk") }
      support_url_text { Faker::Lorem.sentence(word_count: 1, random_words_to_add: 4) }
    end
  end
end
