class StepSummaryTableService
  include ActionView::Helpers::TagHelper

  class << self
    def call(**args)
      new(**args)
    end
  end

  def initialize(step:, steps:, welsh_steps:)
    @step = step
    @steps = steps
    @welsh_steps = welsh_steps
  end

  def values_with_welsh_content
    rows = []

    rows.push(page_heading_row) if @step.respond_to?(:page_heading) && @step.page_heading.present?
    rows.push(guidance_markdown_row) if @step.respond_to?(:guidance_markdown) && @step.guidance_markdown.present?
    rows.push(question_text_row) if @step.page_heading.present?
    rows.push(hint_row) if @step.hint_text.present?
    rows.concat(selection_rows) if @step.answer_type == "selection"
    rows
  end

  def untranslated_content
    return text_row if @step.answer_type == "text"
    return date_row if @step.answer_type == "date"
    return address_row if @step.answer_type == "address"
    return name_row if @step.answer_type == "name"

    generic_row
  end

  def route_content
    conditions_for_step.map do |condition|
      welsh_condition = welsh_condition_from_id(condition.id)
      condition_data = {
        answer_value: condition.answer_value,
        answer_value_cy: welsh_answer_value(welsh_condition),
        goto_page: print_goto_page(condition, @steps),
        goto_page_cy: print_goto_page(welsh_condition, @welsh_steps),
        routing_page: print_routing_page(condition, @steps),
        routing_page_cy: print_routing_page(welsh_condition, @welsh_steps),
        check_page: print_check_page(condition, @steps),
        check_page_cy: print_check_page(welsh_condition, @welsh_steps),
        secondary_skip: condition.secondary_skip?,
        exit_page: condition.exit_page?,
        exit_page_heading: condition.exit_page_heading,
        exit_page_heading_cy: welsh_condition.exit_page_heading,
        exit_page_markdown: condition.exit_page_markdown,
        exit_page_markdown_cy: welsh_condition.exit_page_markdown,
      }
      condition_data
    end
  end

private

  def page_heading_row
    [
      I18n.t("step_summary_card.page_heading"),
      @step.page_heading,
      welsh_step.page_heading,
    ]
  end

  def question_text_row
    [
      I18n.t("step_summary_card.question_text"),
      @step.question_text,
      welsh_step.question_text,
    ]
  end

  def markdown_content
    safe_join(['<pre class="app-markdown-editor__markdown-example-block">'.html_safe, @step.guidance_markdown, "</pre>".html_safe])
  end

  def markdown_content_cy
    safe_join(['<pre class="app-markdown-editor__markdown-example-block">'.html_safe, welsh_step.guidance_markdown, "</pre>".html_safe])
  end

  def guidance_markdown_row
    [
      I18n.t("step_summary_card.guidance_markdown"),
      markdown_content,
      markdown_content_cy,
    ]
  end

  def hint_row
    [I18n.t("step_summary_card.hint_text"),
     @step.hint_text,
     welsh_step.hint_text]
  end

  def generic_row
    {
      summary: I18n.t("step_summary_card.answer_type"),
      text: I18n.t("helpers.label.page.answer_type_options.names.#{@step.answer_type}"),
    }
  end

  def selection_rows
    rows = [[I18n.t("step_summary_card.options_title"), selection_list, selection_list_cy]]

    none_of_the_above_question_text = get_none_of_the_above_question_text
    none_of_the_above_question_text_cy = get_none_of_the_above_question_text_cy
    if @step.is_optional? && none_of_the_above_question_text.present?
      rows << [
        I18n.t("step_summary_card.none_of_the_above_question_title"),
        none_of_the_above_question_text,
        none_of_the_above_question_text_cy,
      ]
    end
    rows
  end

  def selection_answer_type
    return I18n.t("step_summary_card.selection_type.default") unless @step.answer_settings.only_one_option == "true"

    I18n.t("step_summary_card.selection_type.only_one_option")
  end

  def selection_list
    return @step.show_selection_options unless @step.answer_settings.selection_options.length >= 1

    options = @step.answer_settings.selection_options.map(&:name)
    options << I18n.t("step_summary_card.selection_type.none_of_the_above") if @step.is_optional?
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

  def selection_list_cy
    return welsh_step.show_selection_options unless welsh_step.answer_settings.selection_options.length >= 1

    options = welsh_step.answer_settings.selection_options.map(&:name)
    options << I18n.t("step_summary_card.selection_type.none_of_the_above") if welsh_step.is_optional?
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

  def get_none_of_the_above_question_text
    none_of_the_above_question = @step.answer_settings.none_of_the_above_question
    return nil if none_of_the_above_question.blank? || none_of_the_above_question.question_text.blank?

    if ActiveRecord::Type::Boolean.new.cast(none_of_the_above_question.is_optional)
      I18n.t("step_summary_card.none_of_the_above_question_optional", question_text: none_of_the_above_question.question_text)
    else
      none_of_the_above_question.question_text
    end
  end

  def get_none_of_the_above_question_text_cy
    none_of_the_above_question = welsh_step.answer_settings.none_of_the_above_question
    return nil if none_of_the_above_question.blank? || none_of_the_above_question.question_text.blank?

    if ActiveRecord::Type::Boolean.new.cast(none_of_the_above_question.is_optional)
      I18n.t("step_summary_card.none_of_the_above_question_optional", question_text: none_of_the_above_question.question_text)
    else
      none_of_the_above_question.question_text
    end
  end

  def text_row
    {
      summary: I18n.t("step_summary_card.answer_type"),
      text: I18n.t("helpers.label.page.text_settings_options.names.#{@step.answer_settings.input_type}"),
    }
  end

  def date_row
    {
      summary: I18n.t("step_summary_card.answer_type"),
      text: I18n.t("step_summary_card.date_type.#{@step.answer_settings.input_type}"),
    }
  end

  def address_row
    {
      summary: I18n.t("step_summary_card.answer_type"),
      text: I18n.t("helpers.label.page.address_settings_options.names.#{address_input_type_to_string}"),
    }
  end

  def name_row
    {
      summary: I18n.t("step_summary_card.answer_type"),
      text: name_answer_type,
    }
  end

  def name_answer_type
    title_needed = if @step.answer_settings.title_needed == "true"
                     I18n.t("step_summary_card.name_type.title_selected")
                   else
                     I18n.t("step_summary_card.name_type.title_not_selected")
                   end

    settings = [I18n.t("helpers.label.page.answer_type_options.names.#{@step.answer_type}"),
                I18n.t("helpers.label.page.name_settings_options.names.#{@step.answer_settings.input_type}")]
    settings << title_needed

    formatted_list = html_list_item(settings)

    ActionController::Base.helpers.sanitize("<ul class='govuk-list'>#{formatted_list}</ul>")
  end

  def address_input_type_to_string
    input_type = @step.answer_settings.input_type
    if input_type.uk_address == "true" && input_type.international_address == "true"
      "uk_and_international_addresses"
    elsif input_type.uk_address == "true"
      "uk_addresses"
    else
      "international_addresses"
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

  def welsh_step
    @welsh_steps.find { |welsh_step| welsh_step.id == @step.id }
  end

  def step_from_id(id)
    @steps.find { |welsh_step| welsh_step.id == id }
  end

  def welsh_step_from_id(id)
    @welsh_steps.find { |step| step.id == id }
  end

  def conditions_for_step
    @steps.flat_map(&:routing_conditions).filter { |condition| condition.check_page_id == @step.id }
  end

  def welsh_condition_from_id(condition_id)
    @welsh_steps.flat_map(&:routing_conditions).find { |welsh_condition| welsh_condition.id == condition_id }
  end

  def build_title(step)
    question_text = ActionController::Base.helpers.sanitize(step.question_text)

    "#{step.position}. #{question_text}"
  end

  def print_goto_page(condition, steps, locale: "en")
    return I18n.t("step_summary_card.end_of_form.#{locale}") if condition.skip_to_end
    return condition.exit_page_heading if condition.exit_page?

    build_title(steps.find { |step| step.id == condition.goto_page_id })
  end

  def print_routing_page(condition, steps)
    build_title(steps.find { |step| step.id == condition.routing_page_id })
  end

  def print_check_page(condition, steps)
    build_title(steps.find { |step| step.id == condition.check_page_id })
  end

  def welsh_answer_value(welsh_condition)
    return nil if welsh_condition.answer_value.blank?

    @welsh_steps.find { |step| step.id == welsh_condition.check_page_id }.answer_settings.selection_options.find { |option| option.value == welsh_condition.answer_value }.name
  end
end
