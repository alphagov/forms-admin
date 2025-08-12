FactoryBot.define do
  factory :page, parent: :page_record

  trait :with_file_upload_answer_type do
    answer_type { "file" }
  end
end
