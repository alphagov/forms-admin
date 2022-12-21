FactoryBot.define do
  factory :date_settings_form, class: "Forms::DateSettingsForm" do
    input_type { Forms::DateSettingsForm::INPUT_TYPES.sample }
  end
end
