FactoryBot.define do
  factory :type_of_answer_form, class: "Forms::TypeOfAnswerForm" do
    answer_type { Page::ANSWER_TYPES.sample }
    form { build :form }
  end
end
