FactoryBot.define do
  factory :address_settings_form, class: "Forms::AddressSettingsForm" do
    uk_address { "true" }
    international_address { "true" }
  end
end
