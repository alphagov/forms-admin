FactoryBot.define do
  factory :type_of_answer_form, class: "Forms::TypeOfAnswerForm" do
    answer_type { Page::ANSWER_TYPES.sample }
    form { build :form }

    trait :without_selection_answer_type do
      answer_type { %w[single_line number address date email national_insurance_number phone_number long_text].sample }
    end
  end
end
