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

    options.concat(hint_options) if @page.hint_text?.present?
    options.concat(generic_options) if @read_only && %w[address date text selection name].exclude?(@page.answer_type)

    options.concat(selection_options) if @page.answer_type == "selection"
    options.concat(text_options) if @page.answer_type == "text"
    options.concat(date_options) if @page.answer_type == "date"
    options.concat(address_options) if @page.answer_type == "address"
    options.concat(name_options) if @page.answer_type == "name"
    options
  end

private

  def hint_options
    [{
      key: I18n.t("page_options_service.hint_text"),
      value: @page.hint_text,
    }]
  end

  def generic_options
    [].tap do |options|
      options << {
        key: I18n.t("page_options_service.answer_type"),
        value: I18n.t("helpers.label.page.answer_type_options.names.#{@page.answer_type}"),
      }
    end
  end

  def selection_options
    [
      { key: I18n.t("page_options_service.answer_type"), value: selection_answer_type },
      { key: I18n.t("selections_settings.options_title"), value: selection_list },
    ]
  end

  def selection_answer_type
    return I18n.t("page_options_service.selection_type.default") unless @page.answer_settings.only_one_option == "true"

    I18n.t("page_options_service.selection_type.only_one_option")
  end

  def selection_list
    return @page.show_selection_options unless @page.answer_settings.selection_options.map(&:name).length >= 1

    options = @page.answer_settings.selection_options.map(&:name)
    options << "#{I18n.t('page_options_service.selection_type.none_of_the_above')}</li>" if @page.is_optional?
    formatted_list = options.join("</li><li>")

    ActionController::Base.helpers.sanitize("<ul class='govuk-list'><li>#{formatted_list}</li></ul>")
  end

  def text_options
    [{ key: I18n.t("page_options_service.answer_type"), value: I18n.t("helpers.label.page.text_settings_options.names.#{@page.answer_settings.input_type}") }]
  end

  def date_options
    [{ key: I18n.t("page_options_service.answer_type"), value: date_answer_type_text }]
  end

  def date_answer_type_text
    return I18n.t("helpers.label.page.date_settings_options.input_types.#{@page.answer_settings.input_type}") if @page.answer_settings.input_type.to_sym == :date_of_birth

    I18n.t("page_options_service.date")
  end

  def address_options
    [{ key: I18n.t("page_options_service.answer_type"), value: I18n.t("helpers.label.page.address_settings_options.names.#{address_input_type_to_string}") }]
  end

  def name_options
    [{ key: I18n.t("page_options_service.answer_type"), value: name_answer_type }]
  end

  def name_answer_type
    title_needed = if @page.answer_settings.title_needed == "true"
                     I18n.t("page_options_service.name_type.title_selected")
                   else
                     I18n.t("page_options_service.name_type.title_not_selected")
                   end

    settings = [I18n.t("helpers.label.page.answer_type_options.names.#{@page.answer_type}"),
                I18n.t("helpers.label.page.name_settings_options.names.#{@page.answer_settings.input_type}")]
    settings << title_needed

    formatted_list = settings.join("</li><li>")

    ActionController::Base.helpers.sanitize("<ul class='govuk-list'><li>#{formatted_list}</li></ul>")
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
