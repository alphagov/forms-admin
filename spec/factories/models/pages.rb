# When an OpenStruct is converted to json, it inludes @table.
# We inherit and overide as_json here to use to contain answer_settings, which
# is a json hash converted into an object by ActiveResource. Using a plain hash
# for answer_settings means there is no .access to attributes.
class DataStruct < OpenStruct
  def as_json(*args)
    super.as_json["table"]
  end
end

FactoryBot.define do
  factory :page, class: "Page" do
    sequence(:id) { |n| n }
    question_text { Faker::Lorem.question }
    answer_type { Page::ANSWER_TYPES.reject { |item| Page::ANSWER_TYPES_WITH_SETTINGS.include? item }.sample }
    is_optional { nil }
    answer_settings { nil }
    hint_text { nil }
    routing_conditions { [] }
    sequence(:position) { |n| n }
    question_with_text { "#{position}. #{question_text}" }
    has_routing_errors { false }

    trait :with_hints do
      hint_text { Faker::Quote.yoda }
    end

    trait :with_simple_answer_type do
      answer_type { Page::ANSWER_TYPES.reject { |item| Page::ANSWER_TYPES_WITH_SETTINGS.include? item }.sample }
    end

    trait :with_selections_settings do
      transient do
        only_one_option { "true" }
        selection_options { [Forms::SelectionOption.new({ name: "Option 1" }), Forms::SelectionOption.new({ name: "Option 2" })] }
      end

      question_text { Faker::Lorem.question }
      answer_type { "selection" }
      answer_settings { DataStruct.new(only_one_option:, selection_options:) }
    end

    trait :with_text_settings do
      transient do
        input_type { Forms::TextSettingsForm::INPUT_TYPES.sample }
      end

      answer_type { "text" }
      answer_settings { DataStruct.new(input_type:) }
    end

    trait :with_date_settings do
      transient do
        input_type { Forms::DateSettingsForm::INPUT_TYPES.sample }
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
        input_type { Forms::NameSettingsForm::INPUT_TYPES.sample }
        title_needed { Forms::NameSettingsForm::TITLE_NEEDED.sample }
      end

      answer_type { "name" }
      answer_settings { DataStruct.new(input_type:, title_needed:) }
    end
  end
end
