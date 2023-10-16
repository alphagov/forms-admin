FactoryBot.define do
  factory :question_text_form, class: "Pages::QuestionTextForm" do
    question_text { Faker::Lorem.question.truncate(250) }
    draft_question { build :draft_question, answer_type: "selection", form_id: 1 }
  end
end
