FactoryBot.define do
  factory :page, class: "Page" do
    question_text { Faker::Lorem.question }
    answer_type { %w[single_line number address date email national_insurance_number phone_number long_text selection organisation_name].sample }
    is_optional { nil }
    answer_settings { nil }

    trait :with_hints do
      hint_text { Faker::Quote.yoda }
    end

    trait :without_selection_answer_type do
      answer_type { %w[single_line number address date email national_insurance_number phone_number long_text organisation_name].sample }
    end

    trait :with_selections_settings do
      answer_type { "selection" }
      answer_settings { { only_one_option: "true", selection_options: [Forms::SelectionOption.new({ name: "Option 1" }), Forms::SelectionOption.new({ name: "Option 2" })] } }
    end
  end
end
