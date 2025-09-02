FactoryBot.define do
  factory :form_document_step, class: "FormDocument::Step" do
    id { |n| n }
    type { "question_page" }
    position { |n| n }
    next_step_id { nil }
    data do
      DataStruct.new({
        is_optional:,
        page_heading:,
        question_text:,
        answer_type:,
        answer_settings:,
        guidance_markdown:,
      })
    end

    transient do
      is_optional { false }
      page_heading { nil }
      question_text { Faker::Lorem.question.truncate(250) }
      answer_type { Page::ANSWER_TYPES_WITHOUT_SETTINGS.sample }
      answer_settings { nil }
      guidance_markdown { nil }
    end

    trait :with_selection_settings do
      transient do
        only_one_option { "true" }
        selection_options { [{ name: "Option 1" }, { name: "Option 2" }] }
      end

      answer_type { "selection" }
      answer_settings { DataStruct.new(only_one_option:, selection_options:) }
    end

    trait :with_guidance do
      page_heading { Faker::Quote.yoda.truncate(250) }
      guidance_markdown { "## List of items \n\n\n #{Faker::Markdown.ordered_list}" }
    end

    trait :with_file_upload_answer_type do
      answer_type { "file" }
    end
  end
end
