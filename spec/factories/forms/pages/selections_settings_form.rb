FactoryBot.define do
  factory :selections_settings_form, class: "Pages::SelectionsSettingsForm" do
    selection_options { [{ name: "Option 1" }, { name: "Option 2" }] }
    only_one_option { "true" }
    include_none_of_the_above { true }
    draft_question { build :draft_question, answer_type: "selection", answer_settings: { only_one_option:, selection_options: } }
  end
end
