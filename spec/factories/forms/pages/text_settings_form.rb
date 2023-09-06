FactoryBot.define do
  factory :text_settings_form, class: "Pages::TextSettingsForm" do
    input_type { Pages::TextSettingsForm::INPUT_TYPES.sample }
  end
end
