FactoryBot.define do
  factory :condition, class: "Condition" do
    routing_page_id { nil }
    check_page_id { nil }
    answer_value { nil }
    goto_page_id { nil }
    validation_errors { [] }

    trait :with_answer_value_missing do
      answer_value { nil }
      validation_errors { [OpenStruct.new(name: "answer_value_doesnt_exist")] }
    end

    trait :with_goto_page_missing do
      goto_page_id { nil }
      validation_errors { [OpenStruct.new(name: "goto_page_doesnt_exist")] }
    end

    trait :with_answer_value_and_goto_page_missing do
      goto_page_id { nil }
      validation_errors { [OpenStruct.new(name: "answer_value_doesnt_exist"), OpenStruct.new(name: "goto_page_doesnt_exist")] }
    end
  end
end
