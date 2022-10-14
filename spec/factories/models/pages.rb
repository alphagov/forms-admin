FactoryBot.define do
  factory :page, class: "Page" do
    question_text { Faker::Lorem.question }
    answer_type { %w[single_line number address date email national_insurance_number phone_number].sample }
    is_optional { nil }

    trait :with_hints do
      hint_text { Faker::Quote.yoda }
    end
  end
end
