FactoryBot.define do
  factory :name_settings_form, class: "Forms::NameSettingsForm" do
    input_type { "full_name" }
    title_needed { "true" }
  end
end
