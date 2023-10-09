FactoryBot.define do
  factory :selections_settings_form, class: "Pages::SelectionsSettingsForm" do
    selection_options { [{ "name": "Option 1" }, { "name": "Option 2" }] }
    only_one_option { "true" }
    include_none_of_the_above { true }
  end
end
