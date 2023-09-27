FactoryBot.define do
  factory :draft_question do
    form_id { 1 }
    user { nil }
    sequence(:page_id) { |n| n }
    question_text { Faker::Lorem.question }
    hint_text { nil }
    is_optional { false }
    answer_type { Page::ANSWER_TYPES.reject { |item| Page::ANSWER_TYPES_WITH_SETTINGS.include? item }.sample }
    page_heading { nil }
    guidance_markdown { nil }
    answer_settings { {} }

    trait :with_hints do
      hint_text { Faker::Quote.yoda }
    end

    trait :with_guidance do
      page_heading { Faker::Quote.yoda }
      guidance_markdown { "## List of items \n\n\n #{Faker::Markdown.ordered_list}" }
    end

    trait :with_simple_answer_type do
      answer_type { Page::ANSWER_TYPES.reject { |item| Page::ANSWER_TYPES_WITH_SETTINGS.include? item }.sample }
    end
  end
end
