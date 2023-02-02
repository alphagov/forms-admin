# frozen_string_literal: true

require "govuk/components"
class SummaryCardComponent::ViewPreview < ViewComponent::Preview
  def with_no_action_links
    render(SummaryCardComponent::View.new(title: "2. How old are you?", rows: [
      { key: "Hint", value: "Enter your date of birth" },
      { key: "Answer type", value: "Date" },
      { key: "Input type", value: "Date of birth" },
    ]))
  end

  def with_hint_text_in_title
    render(SummaryCardComponent::View.new(title: "What is your full name?", hint: "For example as shown on a passport", rows: [
      { key: "First names", value: "Mike" },
      { key: "Middle names", value: "Larson" },
      { key: "Last name", value: "Doyle" },
    ]))
  end

  def with_question_numbers_added_to_title
    render(SummaryCardComponent::View.new(title: "1. What is your date of birth?", rows: [
      { key: "Hint", value: "Enter your date of birth" },
      { key: "Answer type", value: "Date" },
      { key: "Input type", value: "Date of birth" },
    ]))
  end

  def with_action_links
    render(SummaryCardComponent::View.new(title: "Personal Details", rows: [
      {
        key: "First names",
        value: "Mike",
        action_href: "#mike",
        action_text: "Change",
        action_visually_hidden_text: "first names",
      },
      {
        key: "Middle names",
        value: "Larson",
      },
      {
        key: "Last name",
        value: "Doyle",
        action_href: "http://example.com",
        action_text: "Delete",
        action_visually_hidden_text: "last name",
      },
    ]))
  end

  def answer_types_01_person_name_with_full_name_details_no_title
    options = [I18n.t("helpers.label.page.answer_type_options.names.name")]
    options << I18n.t("helpers.label.page.name_settings_options.input_types.first_middle_and_last_name")
    options << "Title not needed"

    render(SummaryCardComponent::View.new(title: "What is your full name? (Optional)", hint: "As it appears in your passport",
                                          rows: [
                                            { key: "Answer type", value: ActionController::Base.helpers.sanitize("<ul class='govuk-list'><li>#{options.split(' ').join('</li><li>')}</li></ul>") },
                                          ]))
  end

  def answer_types_01_person_name_with_first_and_last_details_and_title
    options = [I18n.t("helpers.label.page.answer_type_options.names.name")]
    options << I18n.t("helpers.label.page.name_settings_options.input_types.first_and_last_name")
    options << "Title needed"

    render(SummaryCardComponent::View.new(title: "What is your full name? (Optional)", hint: "As it appears in your passport",
                                          rows: [
                                            { key: "Answer type", value: ActionController::Base.helpers.sanitize("<ul class='govuk-list'><li>#{options.split(' ').join('</li><li>')}</li></ul>") },
                                          ]))
  end

  def answer_types_02_company_or_org_name
    render(SummaryCardComponent::View.new(title: "Who do you work for?", hint: "Think carefully", rows: [
      { key: "Answer type", value: I18n.t("helpers.label.page.answer_type_options.names.organisation_name") },
    ]))
  end

  def answer_types_03_email
    render(SummaryCardComponent::View.new(title: "What is your email address?", hint: "example@example.gov.uk", rows: [
      { key: "Answer type", value: I18n.t("helpers.label.page.answer_type_options.names.email") },
    ]))
  end

  def answer_types_04_phone_number
    render(SummaryCardComponent::View.new(title: "What is your phone number?", hint: "Mobile number or landline", rows: [
      { key: "Answer type", value: I18n.t("helpers.label.page.answer_type_options.names.phone_number") },
    ]))
  end

  def answer_types_05_ni_number
    render(SummaryCardComponent::View.new(title: "What is your NI number?", hint: "AB123456C", rows: [
      { key: "Answer type", value: I18n.t("helpers.label.page.answer_type_options.names.national_insurance_number") },
    ]))
  end

  def answer_types_06_addresses_uk_address
    render(SummaryCardComponent::View.new(title: "Where in do you live?", hint: "Must be based in UK", rows: [
      { key: "Answer type", value: I18n.t("helpers.label.page.address_settings_options.names.uk_addresses") },
    ]))
  end

  def answer_types_06_addresses_international_address
    render(SummaryCardComponent::View.new(title: "Where in do you live?", hint: "Must be based outside the UK", rows: [
      { key: "Answer type", value: I18n.t("helpers.label.page.address_settings_options.names.international_addresses") },
    ]))
  end

  def answer_types_06_addresses_uk_and_international_address
    render(SummaryCardComponent::View.new(title: "Where in do you live?", hint: "Please be specific as possible", rows: [
      { key: "Answer type", value: I18n.t("helpers.label.page.address_settings_options.names.uk_and_international_addresses") },
    ]))
  end

  def answer_types_07_dates_dob
    render(SummaryCardComponent::View.new(title: "What is you date of birth?", hint: "As it appears in your passport", rows: [
      { key: "Answer type", value: "Date of birth" },
    ]))
  end

  def answer_types_07_dates_other
    render(SummaryCardComponent::View.new(title: "What is todays date?", hint: "The day after yesterday but the day before tomorrow", rows: [
      { key: "Answer type", value: "Date" },
    ]))
  end

  def answer_types_08_selection_from_list_select_one_option
    options = "body cowboy affect southern feet football fill they jack aboard leather total everybody flame straw opportunity equally connected brave hospital"
    render(SummaryCardComponent::View.new(title: "Which option do you like the look of?", hint: "Select all that apply",
                                          rows: [
                                            { key: "Answer type", value: "Selection from a list, one option only." },
                                            { key: I18n.t("selections_settings.options_title"), value: ActionController::Base.helpers.sanitize("<ul class='govuk-list'><li>#{options.split(' ').join('</li><li>')}</li></ul>") },
                                          ]))
  end

  def answer_types_08_selection_from_list_optional
    options = "body cowboy affect southern feet football fill they jack aboard leather total everybody flame straw opportunity equally connected brave hospital"
    render(SummaryCardComponent::View.new(title: "Which option do you like the look of?",
                                          rows: [
                                            { key: "Answer type", value: "Selection from a list" },
                                            { key: I18n.t("selections_settings.options_title"), value: ActionController::Base.helpers.sanitize("<ul class='govuk-list'><li>#{options.split(' ').concat(['None of the above']).join('</li><li>')}</li></ul>") },
                                          ]))
  end

  def answer_types_09_number
    render(SummaryCardComponent::View.new(title: "How old are you?", hint: "0-99", rows: [
      { key: "Answer type", value: I18n.t("helpers.label.page.answer_type_options.names.number") },
    ]))
  end

  def answer_types_10_text_long_text
    render(SummaryCardComponent::View.new(title: "What is the meaning of life?", hint: "Hitchhikers Guid to the Galaxy", rows: [
      { key: "Answer type", value: I18n.t("helpers.label.page.text_settings_options.names.long_text") },
    ]))
  end

  def answer_types_10_text_single_line_of_text
    render(SummaryCardComponent::View.new(title: "What is the meaning of life?", hint: "Hitchhikers Guid to the Galaxy", rows: [
      { key: "Answer type", value: I18n.t("helpers.label.page.answer_type_options.names.single_line") },
    ]))
  end
end
