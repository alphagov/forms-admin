FactoryBot.define do
  factory :text_settings_form, class: "Pages::TextSettingsForm" do
    input_type { Pages::TextSettingsForm::INPUT_TYPES.sample }
    draft_question { build :draft_question, answer_type: "text" }
  end
end
