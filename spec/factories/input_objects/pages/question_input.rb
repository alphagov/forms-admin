FactoryBot.define do
  factory :question_input, class: "Pages::QuestionInput" do
    answer_type { Page::ANSWER_TYPES_WITHOUT_SETTINGS.sample }
    question_text { Faker::Lorem.question }
    hint_text { nil }
    is_optional { "false" }
    is_repeatable { "false" }
    answer_settings { nil }
    page_heading { nil }
    guidance_markdown { nil }
    draft_question { build :draft_question, question_text: }

    trait :with_hints do
      hint_text { Faker::Quote.yoda }
    end

    trait :with_guidance do
      page_heading { Faker::Quote.yoda }
      guidance_markdown { "## List of items \n\n\n #{Faker::Markdown.ordered_list}" }
    end
  end
end
