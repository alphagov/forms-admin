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
  factory :page_record, class: "Page" do
    association :form, factory: :form_record

    question_text { Faker::Lorem.question }
    answer_type { Page::ANSWER_TYPES.sample }
    is_optional { false }
    answer_settings { nil }
    sequence(:position)
    routing_conditions { [] }
    check_conditions { [] }
    goto_conditions { [] }
    page_heading { nil }
    guidance_markdown { nil }

    trait :with_guidance do
      page_heading { Faker::Quote.yoda }
      guidance_markdown { "## List of items \n\n\n #{Faker::Markdown.ordered_list}" }
    end

    trait :with_hints do
      hint_text { Faker::Quote.yoda }
    end

    trait :with_selections_settings do
      transient do
        only_one_option { "true" }
        selection_options { [{ name: "Option 1" }, { name: "Option 2" }] }
      end

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
  end
end
