FactoryBot.define do
  factory :form_submission_email, class: "FormSubmissionEmail" do
    sequence(:form_id) { |n| "Form #{n}" }
  end
end
