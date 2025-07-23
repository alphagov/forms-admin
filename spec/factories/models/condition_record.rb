FactoryBot.define do
  factory :condition_record, class: "Condition" do
    transient do
      form { build(:form_record) }
    end

    routing_page { association :page_record, form: }
    check_page { nil }
    goto_page { nil }
    answer_value { nil }
    skip_to_end { false }
    exit_page_heading { nil }
    exit_page_markdown { nil }

    trait :with_answer_value_missing do
      goto_page { association :page_record, form: }

      check_page { association :page_record, :with_selection_settings, form: }
      answer_value { nil }
    end

    trait :with_goto_page_missing do
      goto_page { nil }
    end

    trait :with_goto_page_before_check_page do
      check_page { association :page_record, form:, position: 5 }
      goto_page { association :page_record, form:, position: 3 }
    end

    trait :with_goto_page_immediately_after_check_page do
      routing_page { association :page_record, form:, position: 5 }
      check_page { routing_page }
      goto_page { association :page_record, form:, position: 6 }
    end

    trait :with_answer_value_and_goto_page_missing do
      goto_page { nil }

      check_page { association :page_record, :with_selection_settings, form: }
      answer_value { nil }
    end

    trait :with_exit_page do
      goto_page { nil }
      exit_page_heading { "Exit page heading" }
      exit_page_markdown { "Exit page markdown" }
    end
  end
end
