FactoryBot.define do
  factory :type_of_answer_form, class: "Forms::TypeOfAnswerForm" do
    answer_type { Page::ANSWER_TYPES.sample }
    form { build :form }

    trait :with_simple_answer_type do
      answer_type { %w[single_line number email national_insurance_number phone_number long_text organisation_name].sample }
    end
  end
end
