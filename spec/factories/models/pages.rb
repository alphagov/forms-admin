FactoryBot.define do
  factory :page, class: "Page" do
    question_text { Faker::Lorem.question }
    answer_type { %w[single_line address date email national_insurance_number phone_number].sample }

    trait :with_hints do
      hint_text { Faker::Quote.yoda }
    end
  end
end
