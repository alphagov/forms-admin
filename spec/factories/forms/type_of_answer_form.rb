FactoryBot.define do
  factory :type_of_answer_form, class: "Forms::TypeOfAnswerForm" do
    answer_type { Page::ANSWER_TYPES.sample }
    form { build :form }

    trait :with_simple_answer_type do
      if FeatureService.enabled?(:autocomplete_answer_types)
        answer_type { %w[single_line number address email national_insurance_number phone_number long_text organisation_name].sample }
      else
        answer_type { %w[single_line number address email national_insurance_number phone_number long_text].sample }
      end
    end
  end
end
