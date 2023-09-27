FactoryBot.define do
  factory :type_of_answer_form, class: "Pages::TypeOfAnswerForm" do
    answer_type { Page::ANSWER_TYPES.sample }
    draft_question { nil }

    trait :with_simple_answer_type do
      answer_type { Page::ANSWER_TYPES.reject { |item| Page::ANSWER_TYPES_WITH_SETTINGS.include? item }.sample }
    end
  end
end
