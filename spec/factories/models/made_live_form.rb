FactoryBot.define do
  factory :made_live_form, class: "Api::V1::FormResource" do
    sequence(:name) { |n| "Form #{n}" }
    sequence(:form_slug) { |n| "form-#{n}" }
    submission_email { Faker::Internet.email(domain: "example.gov.uk") }
    submission_type { "email" }
    privacy_policy_url { Faker::Internet.url(host: "gov.uk") }
    language { "en" }
    support_email { nil }
    support_phone { nil }
    support_url { nil }
    support_url_text { nil }
    what_happens_next_markdown { "We usually respond to applications within 10 working days." }
    declaration_text { nil }
    question_section_completed { true }
    declaration_section_completed { true }
    share_preview_completed { true }
    creator_id { nil }
    start_page { nil }
    live_at { Time.zone.now.to_s }

    pages do
      Array.new(5) { association(:made_live_page) }
    end

    trait :with_one_page do
      pages { [association(:made_live_page)] }
    end
  end
end
