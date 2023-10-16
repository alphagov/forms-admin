FactoryBot.define do
  factory :date_settings_form, class: "Pages::DateSettingsForm" do
    input_type { Pages::DateSettingsForm::INPUT_TYPES.sample }
    draft_question { build :draft_question, answer_type: "date" }
  end
end
