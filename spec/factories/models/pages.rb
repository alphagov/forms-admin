FactoryBot.define do
  factory :page, class: "Page" do
    association :form, factory: :form

    question_text { Faker::Lorem.question.truncate(250) }
    answer_type { Page::ANSWER_TYPES_WITHOUT_SETTINGS.sample }
    is_optional { false }
    answer_settings { nil }
    hint_text { nil }
    sequence(:position)
    routing_conditions { [] }
    check_conditions { [] }
    goto_conditions { [] }
    page_heading { nil }
    guidance_markdown { nil }
    is_repeatable { false }

    trait :with_hints do
      hint_text { Faker::Quote.yoda.truncate(500) }
    end

    trait :with_guidance do
      page_heading { Faker::Quote.yoda.truncate(250) }
      guidance_markdown { "## List of items \n\n\n #{Faker::Markdown.ordered_list}" }
    end

    trait :with_simple_answer_type do
      answer_type { Page::ANSWER_TYPES_WITHOUT_SETTINGS.sample }
    end

    trait :with_selection_settings do
      transient do
        only_one_option { "true" }
        selection_options { [{ name: "Option 1" }, { name: "Option 2" }] }
      end

      question_text { Faker::Lorem.question }
      answer_type { "selection" }
      answer_settings { DataStruct.new(only_one_option:, selection_options:) }
    end

    trait :selection_with_radios do
      answer_type { "selection" }
      answer_settings do
        {
          only_one_option: "true",
          selection_options: (1..30).to_a.map { |i| { name: i.to_s } },
        }
      end
    end

    trait :selection_with_autocomplete do
      answer_type { "selection" }
      answer_settings do
        {
          only_one_option: "true",
          selection_options: (1..31).to_a.map { |i| { name: i.to_s } },
        }
      end
    end

    trait :selection_with_checkboxes do
      answer_type { "selection" }
      answer_settings do
        {
          only_one_option: "false",
          selection_options: [{ name: "Option 1" }, { name: "Option 2" }],
        }
      end
    end

    trait :with_text_settings do
      transient do
        input_type { Pages::TextSettingsInput::INPUT_TYPES.sample }
      end

      answer_type { "text" }
      answer_settings { DataStruct.new(input_type:) }
    end

    trait :with_single_line_text_settings do
      answer_type { "text" }
      answer_settings { DataStruct.new(input_type: "single_line") }
    end

    trait :with_date_settings do
      transient do
        input_type { Pages::DateSettingsInput::INPUT_TYPES.sample }
      end

      answer_type { "date" }
      answer_settings { DataStruct.new(input_type:) }
    end

    trait :with_address_settings do
      transient do
        uk_address { "true" }
        international_address { "true" }
      end

      answer_type { "address" }
      answer_settings { DataStruct.new(input_type: DataStruct.new(uk_address:, international_address:)) }
    end

    trait :with_name_settings do
      transient do
        input_type { Pages::NameSettingsInput::INPUT_TYPES.sample }
        title_needed { Pages::NameSettingsInput::TITLE_NEEDED.sample }
      end

      answer_type { "name" }
      answer_settings { DataStruct.new(input_type:, title_needed:) }
    end

    trait :with_full_name_settings do
      answer_type { "name" }
      answer_settings { DataStruct.new(input_type: "full_name", title_needed: false) }
    end

    trait :with_file_upload_answer_type do
      answer_type { "file" }
    end
  end
end
