FactoryBot.define do
  factory :text_settings_input, class: "Pages::TextSettingsInput" do
    input_type { Pages::TextSettingsInput::INPUT_TYPES.sample }
    draft_question { build :draft_question, answer_type: "text" }
  end
end
