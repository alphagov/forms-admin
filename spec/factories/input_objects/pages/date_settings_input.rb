FactoryBot.define do
  factory :date_settings_input, class: "Pages::DateSettingsInput" do
    input_type { Pages::DateSettingsInput::INPUT_TYPES.sample }
    draft_question { build :draft_question, answer_type: "date" }
  end
end
