FactoryBot.define do
  factory :condition, class: "Condition" do
    routing_page_id { nil }
    check_page_id { nil }
    answer_value { nil }
    goto_page_id { nil }
    skip_to_end { false }
    validation_errors { [] }
    has_routing_errors { false }

    trait :with_answer_value_missing do
      answer_value { nil }
      has_routing_errors { true }
      validation_errors { [OpenStruct.new(name: "answer_value_doesnt_exist")] }
    end

    trait :with_goto_page_missing do
      goto_page_id { nil }
      has_routing_errors { true }
      validation_errors { [OpenStruct.new(name: "goto_page_doesnt_exist")] }
    end

    trait :with_goto_page_before_check_page do
      has_routing_errors { true }
      validation_errors { [OpenStruct.new(name: "cannot_have_goto_page_before_routing_page")] }
    end

    trait :with_goto_page_immediately_after_check_page do
      has_routing_errors { true }
      validation_errors { [OpenStruct.new(name: "cannot_route_to_next_page")] }
    end

    trait :with_answer_value_and_goto_page_missing do
      goto_page_id { nil }
      has_routing_errors { true }
      validation_errors { [OpenStruct.new(name: "answer_value_doesnt_exist"), OpenStruct.new(name: "goto_page_doesnt_exist")] }
    end
  end
end
