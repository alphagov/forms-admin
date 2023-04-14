FactoryBot.define do
  factory :condition, class: "OpenStruct" do
    routing_page_id { nil }
    check_page_id { nil }
    answer_value { nil }
    goto_page_id { nil }
  end
end
