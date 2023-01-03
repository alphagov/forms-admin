FactoryBot.define do
  factory :address_settings_form, class: "Forms::AddressSettingsForm" do
    input_type { Forms::AddressSettingsForm::INPUT_TYPES.sample }
  end
end
