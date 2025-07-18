FactoryBot.define do
  factory :page, parent: :page_resource

  trait :with_file_upload_answer_type do
    answer_type { "file" }
  end
end
