FactoryBot.define do
  factory :text_settings_form, class: "Forms::TextSettingsForm" do
    input_type { Forms::TextSettingsForm::INPUT_TYPES.sample }
  end
end
