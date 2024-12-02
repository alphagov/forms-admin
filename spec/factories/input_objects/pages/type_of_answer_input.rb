FactoryBot.define do
  factory :type_of_answer_input, class: "Pages::TypeOfAnswerInput" do
    answer_type { Page::ANSWER_TYPES_EXCLUDING_FILE.sample }
    draft_question { build :draft_question, answer_type: }
    answer_types { Page::ANSWER_TYPES_EXCLUDING_FILE }

    trait :with_simple_answer_type do
      answer_type { Page::ANSWER_TYPES_WITHOUT_SETTINGS.sample }
    end
  end
end
