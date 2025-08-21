class PageOptionsService
  include ActionView::Helpers::TagHelper

  class << self
    def call(**args)
      new(**args)
    end
  end

  def initialize(page:, pages:, read_only: true)
    @read_only = read_only
    @page = page
    @pages = pages
  end

  def all_options_for_answer_type
    options = []

    # Prioritize guidance markdown for file uploads
    options.concat(guidance_markdown_options) if @page.respond_to?(:guidance_markdown) && @page.guidance_markdown.present?

    # Page heading for non-file types
    options.concat(page_heading_options) if @page.respond_to?(:page_heading) && @page.page_heading.present? && @page.answer_type != "file"

    # File upload: If a page heading/guidance is present, show the question text in the body of the summary card
    # as we're using the heading in the title rather than the question text.
    options.concat(question_text_options) if @page.answer_type == "file" && @page.page_heading.present?

    # Other answer types
    options.concat(hint_options) if @page.hint_text?.present?
    options.concat(generic_options) if @read_only && %w[address date text selection name].exclude?(@page.answer_type)

    options.concat(selection_options) if @page.answer_type == "selection"
    options.concat(text_options) if @page.answer_type == "text"
    options.concat(date_options) if @page.answer_type == "date"
    options.concat(address_options) if @page.answer_type == "address"
    options.concat(name_options) if @page.answer_type == "name"
    options.concat(route_options) if @page.respond_to?(:routing_conditions) && @page.routing_conditions.present?
    options
  end

private

  def page_heading_options
    [{
      key: { text: I18n.t("page_options_service.page_heading") },
      value: { text: @page.page_heading },
    }]
  end

  def question_text_options
    [{
      key: { text: I18n.t("reports.form_or_questions_list_table.headings.question_text") },
      value: { text: @page.question_text },
    }]
  end

  def markdown_content
    safe_join(['<pre class="app-markdown-editor__markdown-example-block">'.html_safe, @page.guidance_markdown, "</pre>".html_safe])
  end

  def guidance_markdown_options
    [{
      key: { text: I18n.t("page_options_service.guidance_markdown") },
      value: { text: markdown_content },
    }]
  end

  def hint_options
    [{
      key: { text: I18n.t("page_options_service.hint_text") },
      value: { text: @page.hint_text },
    }]
  end

  def generic_options
    [].tap do |options|
      options << {
        key: { text: I18n.t("page_options_service.answer_type") },
        value: { text: I18n.t("helpers.label.page.answer_type_options.names.#{@page.answer_type}") },
      }
    end
  end

  def selection_options
    [
      { key: { text: I18n.t("page_options_service.answer_type") }, value: { text: selection_answer_type } },
      { key: { text: I18n.t("page_options_service.options_title") }, value: { text: selection_list } },
    ]
  end

  def selection_answer_type
    return I18n.t("page_options_service.selection_type.default") unless @page.answer_settings.only_one_option == "true"

    I18n.t("page_options_service.selection_type.only_one_option")
  end

  def selection_list
    return @page.show_selection_options unless @page.answer_settings.selection_options.length >= 1

    options = @page.answer_settings.selection_options.map { |option| option.attributes[:name] }
    options << I18n.t("page_options_service.selection_type.none_of_the_above") if @page.is_optional?
    formatted_list = html_unordered_list(options)

    if options.length > 10
      details_summary = I18n.t("page_settings_summary.selection.options_summary", number_of_options: options.length)
      GovukComponent::DetailsComponent.new(summary_text: details_summary)
                                      .with_content(formatted_list)
                                      .call
    else
      caption = content_tag(:p, I18n.t("page_settings_summary.selection.options_count", number_of_options: options.length), class: "govuk-body-s")
      safe_join([caption, formatted_list])
    end
  end

  def text_options
    [{ key: { text: I18n.t("page_options_service.answer_type") }, value: { text: I18n.t("helpers.label.page.text_settings_options.names.#{@page.answer_settings.input_type}") } }]
  end

  def date_options
    [{ key: { text: I18n.t("page_options_service.answer_type") }, value: { text: I18n.t("page_options_service.date_type.#{@page.answer_settings.input_type}") } }]
  end

  def address_options
    [{ key: { text: I18n.t("page_options_service.answer_type") }, value: { text: I18n.t("helpers.label.page.address_settings_options.names.#{address_input_type_to_string}") } }]
  end

  def name_options
    [{ key: { text: I18n.t("page_options_service.answer_type") }, value: { text: name_answer_type } }]
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

    formatted_list = html_list_item(settings)

    ActionController::Base.helpers.sanitize("<ul class='govuk-list'>#{formatted_list}</ul>")
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

  def route_options
    [{ key: { text: I18n.t("page_conditions.route") }, value: { text: route_value.html_safe } }]
  end

  def route_value
    if @page.routing_conditions.length == 1
      print_route(@page.routing_conditions.first)
    else
      html_ordered_list(@page.routing_conditions.map { |condition| print_route(condition) })
    end
  end

  def print_route(condition)
    answer_value = ActionController::Base.helpers.sanitize(condition.answer_value)

    if condition.skip_to_end
      I18n.t("page_conditions.condition_compact_html_end_of_form", answer_value:).html_safe
    elsif condition.secondary_skip?
      goto_question = @pages.find { |page| page.id == condition.goto_page_id }
      goto_page_question_text = ActionController::Base.helpers.sanitize(goto_question.question_text)
      goto_page_question_number = @pages.find_index(goto_question) + 1

      I18n.t("page_conditions.condition_compact_html_secondary_skip", goto_page_question_number:, goto_page_question_text:).html_safe
    elsif condition.exit_page?
      I18n.t("page_conditions.condition_compact_html_exit_page", answer_value:, exit_page_heading: condition.exit_page_heading).html_safe
    else
      goto_question = @pages.find { |page| page.id == condition.goto_page_id }
      goto_page_question_text = ActionController::Base.helpers.sanitize(goto_question.question_text)
      goto_page_question_number = @pages.find_index(goto_question) + 1

      I18n.t("page_conditions.condition_compact_html", answer_value:, goto_page_question_number:, goto_page_question_text:).html_safe
    end
  end

  def html_ordered_list(list_items)
    content_tag(:ol, html_list_item(list_items), class: ["govuk-list", "govuk-list--number"])
  end

  def html_unordered_list(list_items)
    content_tag(:ul, html_list_item(list_items), class: ["govuk-list", "govuk-list--bullet"])
  end

  def html_list_item(item)
    item.map { |i| content_tag(:li, i) }.join.html_safe
  end
end
