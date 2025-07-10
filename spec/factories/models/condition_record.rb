FactoryBot.define do
  factory :condition_record, class: "Condition" do
    routing_page { build :page_record }
    check_page { nil }
    goto_page { nil }
    answer_value { nil }
    skip_to_end { false }
  end
end
