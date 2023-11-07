FactoryBot.define do
  factory :type_of_answer_form, class: "Pages::TypeOfAnswerForm" do
    answer_type { Page::ANSWER_TYPES.sample }
    draft_question { build :draft_question, answer_type: }

    trait :with_simple_answer_type do
      answer_type { Page::ANSWER_TYPES_WITHOUT_SETTINGS.sample }
    end
  end
end
