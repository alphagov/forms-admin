FactoryBot.define do
  factory :page, class: "Page" do
    question_text { Faker::Lorem.question }
    answer_type { Page::ANSWER_TYPES.sample }
    is_optional { nil }
    answer_settings { nil }

    trait :with_hints do
      hint_text { Faker::Quote.yoda }
    end

    trait :with_simple_answer_type do
      if FeatureService.enabled?(:autocomplete_answer_types)
        answer_type { %w[single_line number email national_insurance_number phone_number long_text organisation_name].sample }
      else
        answer_type { %w[single_line number email national_insurance_number phone_number long_text].sample }
      end
    end

    trait :with_selections_settings do
      answer_type { "selection" }
      answer_settings { { only_one_option: "true", selection_options: [Forms::SelectionOption.new({ name: "Option 1" }), Forms::SelectionOption.new({ name: "Option 2" })] } }
    end

    trait :with_text_settings do
      answer_type { "text" }
      answer_settings { { input_type: Forms::TextSettingsForm::INPUT_TYPES.sample } }
    end

    trait :with_date_settings do
      answer_type { "date" }
      answer_settings { { input_type: Forms::DateSettingsForm::INPUT_TYPES.sample } }
    end

    trait :with_address_settings do
      answer_type { "address" }
      answer_settings { { input_type: Forms::AddressSettingsForm::INPUT_TYPES.sample } }
    end
  end
end
