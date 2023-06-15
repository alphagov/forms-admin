FactoryBot.define do
  factory :question_text_form, class: "Forms::QuestionTextForm" do
    question_text { Faker::Lorem.question }
  end
end
