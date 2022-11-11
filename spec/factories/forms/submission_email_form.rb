FactoryBot.define do
  factory :submission_email_form, class: "Forms::SubmissionEmailForm" do
    temporary_submission_email { "submit@example.gov.uk" }
    form { build :form }

    trait :with_user do
      current_user { OpenStruct.new(name: "User", email: "user@gov.uk") }
    end
  end
end
