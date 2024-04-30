FactoryBot.define do
  factory :search_input, class: "Forms::SearchInput" do
    sequence(:organisation_id) { |n| n }
  end
end
