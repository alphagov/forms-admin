FactoryBot.define do
  factory :submission_email_form, class: "Forms::SubmissionEmailForm" do
    temporary_submission_email { "submit@example.gov.uk" }
    form { build :form }
    notify_response_id { SecureRandom.uuid }
    confirmation_code { "123456" }
    email_code { confirmation_code }

    trait :with_user do
      user_information { OpenStruct.new(name: "User", email: "user@gov.uk") }
    end
  end
end
