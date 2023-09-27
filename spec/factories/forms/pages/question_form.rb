FactoryBot.define do
  factory :question_form, class: "Pages::QuestionForm" do
    question_text { Faker::Lorem.question }
    hint_text { nil }
    is_optional { nil }
    draft_question { nil }
    answer_type { Page::ANSWER_TYPES.reject { |item| Page::ANSWER_TYPES_WITH_SETTINGS.include? item }.sample }

    trait :with_hints do
      hint_text { Faker::Quote.yoda }
    end
  end
end
