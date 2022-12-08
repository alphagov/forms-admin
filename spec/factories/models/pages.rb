FactoryBot.define do
  factory :page, class: "Page" do
    question_text { Faker::Lorem.question }
    answer_type { %w[single_line number address date email national_insurance_number phone_number long_text selection].sample }
    is_optional { nil }
    answer_settings { nil }

    trait :with_hints do
      hint_text { Faker::Quote.yoda }
    end

    trait :without_selection_answer_type do
      answer_type { %w[single_line number address date email national_insurance_number phone_number long_text].sample }
    end
  end
end
