class PageOptionsService
  class << self
    def call(**args)
      new(**args)
    end
  end

  def initialize(page:, read_only: true)
    @read_only = read_only
    @page = page
  end

  def all_options_for_answer_type
    options = []

    options.concat(generic_options) if @read_only
    options.concat(optional) unless @page.answer_type == "selection"

    options.concat(selection_options) if @page.answer_type == "selection"
    options.concat(text_options) if @page.answer_type == "text"
    options.concat(date_options) if @page.answer_type == "date"
    options.concat(address_options) if @page.answer_type == "address"
    options.concat(name_options) if @page.answer_type == "name"
    options
  end

  def optional
    [{
      key: I18n.t("helpers.label.page.answer_type_options.optional"),
      value: @page.is_optional ? I18n.t("helpers.label.page.answer_type_options.optional_yes") : I18n.t("helpers.label.page.answer_type_options.optional_no"),
    }]
  end

  def generic_options
    [].tap do |options|
      if @page.hint_text?.present?
        options << {
          key: "Hint",
          value: @page.hint_text,
        }
      end

      options << {
        key: "Answer type",
        value: I18n.t("helpers.label.page.answer_type_options.names.#{@page.answer_type}"),
      }
    end
  end

  def selection_options
    [
      { key: I18n.t("selections_settings.options_title"), value: @page.show_selection_options },
      { key: I18n.t("selections_settings.only_one_option"), value: @page.answer_settings.only_one_option == "true" ? I18n.t("selections_settings.yes") : I18n.t("selections_settings.no") },
      { key: I18n.t("selections_settings.include_none_of_the_above"), value: @page.is_optional? ? I18n.t("selections_settings.yes") : I18n.t("selections_settings.no") },
    ]
  end

  def text_options
    [{ key: I18n.t("helpers.label.page.answer_type_options.input_type"), value: I18n.t("helpers.label.page.text_settings_options.names.#{@page.answer_settings.input_type}") }]
  end

  def date_options
    [{ key: I18n.t("helpers.label.page.answer_type_options.input_type"), value: I18n.t("helpers.label.page.date_settings_options.input_types.#{@page.answer_settings.input_type}") }]
  end

  def address_options
    [{ key: I18n.t("helpers.label.page.answer_type_options.input_type"), value: I18n.t("helpers.label.page.address_settings_options.names.#{address_input_type_to_string}") }]
  end

  def name_options
    [{ key: I18n.t("helpers.label.page.answer_type_options.input_type"), value: I18n.t("helpers.label.page.name_settings_options.names.#{@page.answer_settings.input_type}") },
     { key: I18n.t("helpers.label.page.name_settings_options.title_needed.name"), value: I18n.t("helpers.label.page.name_settings_options.names.#{@page.answer_settings.title_needed}") }]
  end

  def address_input_type_to_string
    input_type = @page.answer_settings.input_type
    if input_type.uk_address == "true" && input_type.international_address == "true"
      "uk_and_international_addresses"
    elsif input_type.uk_address == "true"
      "uk_addresses"
    else
      "international_addresses"
    end
  end
end
