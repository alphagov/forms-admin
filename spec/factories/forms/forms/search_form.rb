FactoryBot.define do
  factory :search_form, class: "Forms::SearchForm" do
    sequence(:organisation_id) { |n| n }
  end
end
