FactoryBot.define do
  factory :question_text_form, class: "Pages::QuestionTextForm" do
    question_text { Faker::Lorem.question }
  end
end
