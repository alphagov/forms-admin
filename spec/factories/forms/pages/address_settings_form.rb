FactoryBot.define do
  factory :address_settings_form, class: "Pages::AddressSettingsForm" do
    uk_address { "true" }
    international_address { "true" }
    draft_question { build :draft_question, answer_type: "address" }
  end
end
