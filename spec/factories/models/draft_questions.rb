FactoryBot.define do
  factory :draft_question do
    sequence(:form_id) { |n| n }
    user { build :user }
    sequence(:page_id) { |n| n }
    question_text { Faker::Lorem.question.truncate(250) }
    hint_text { nil }
    is_optional { false }
    is_repeatable { false }
    answer_type { Page::ANSWER_TYPES_WITHOUT_SETTINGS.sample }
    page_heading { nil }
    guidance_markdown { nil }
    answer_settings { {} }

    trait :with_hints do
      hint_text { Faker::Quote.yoda.truncate(500) }
    end

    trait :with_guidance do
      page_heading { Faker::Quote.yoda.truncate(250) }
      guidance_markdown { "## List of items \n\n\n #{Faker::Markdown.ordered_list}" }
    end

    factory :draft_question_for_new_page do
      page_id { nil }
    end

    factory :address_draft_question do
      transient do
        uk_address { "true" }
        international_address { "true" }
      end

      answer_type { "address" }
      answer_settings { { input_type: { uk_address:, international_address: } } }
    end

    factory :date_draft_question do
      transient do
        input_type { Pages::DateSettingsInput::INPUT_TYPES.sample }
      end

      answer_type { "date" }
      answer_settings { { input_type: } }
    end

    factory :name_draft_question do
      transient do
        input_type { Pages::NameSettingsInput::INPUT_TYPES.sample }
        title_needed { Pages::NameSettingsInput::TITLE_NEEDED.sample }
      end

      answer_type { "name" }
      answer_settings { { input_type:, title_needed: } }
    end

    factory :selection_draft_question do
      question_text { Faker::Lorem.question }
      answer_type { "selection" }
      answer_settings { { only_one_option: "true", selection_options: [{ name: "Option 1" }, { name: "Option 2" }] } }
    end

    factory :text_draft_question do
      transient do
        input_type { Pages::TextSettingsInput::INPUT_TYPES.sample }
      end

      answer_type { "text" }
      answer_settings { { input_type: } }
    end
  end
end
