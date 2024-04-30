FactoryBot.define do
  factory :name_settings_input, class: "Pages::NameSettingsInput" do
    input_type { "full_name" }
    title_needed { "true" }
    draft_question { build :draft_question, answer_type: "name" }
  end
end
