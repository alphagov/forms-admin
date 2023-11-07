FactoryBot.define do
  factory :draft_question do
    sequence(:form_id) { |n| n }
    user { build :user }
    sequence(:page_id) { |n| n }
    question_text { Faker::Lorem.question.truncate(250) }
    hint_text { nil }
    is_optional { false }
    answer_type { Page::ANSWER_TYPES_WITHOUT_SETTINGS.sample }
    page_heading { nil }
    guidance_markdown { nil }
    answer_settings { {} }

    factory :draft_question_for_new_page do
      page_id { nil }
    end

    trait :with_hints do
      hint_text { Faker::Quote.yoda.truncate(500) }
    end

    trait :with_guidance do
      page_heading { Faker::Quote.yoda.truncate(250) }
      guidance_markdown { "## List of items \n\n\n #{Faker::Markdown.ordered_list}" }
    end
  end
end
