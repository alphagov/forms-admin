class WelshChangeDetectionService
  # Translatable fields are defined via Mobility's `translates` macro in each model.
  # Access them via Model.mobility_attributes (e.g., Form.mobility_attributes).
  #
  # Some fields are excluded from untranslated content detection:
  # - `name`: Always required and set when Welsh is enabled, so never "untranslated"
  # - `privacy_policy_url`: URL doesn't require translation
  # - `answer_settings`: Contains selection options which are checked separately
  IGNORED_FORM_FIELDS = %w[name privacy_policy_url].freeze
  IGNORED_PAGE_FIELDS = %w[answer_settings].freeze

  def initialize(form)
    @form = form
  end

  def update_welsh?
    return false unless @form.available_languages.include?("cy")

    changes.any?
  end

  def changes
    return [] unless @form.available_languages.include?("cy")

    tag = @form.has_live_version ? :live : :draft
    welsh_doc = FormDocument.find_by(form_id: @form.id, tag:, language: "cy")
    return [{ type: :no_welsh_document }] if welsh_doc.blank?

    welsh_content = welsh_doc.content
    current_content = @form.as_form_document(language: :en)

    detected_changes = []
    detected_changes.concat(detect_form_field_changes(welsh_content, current_content))
    detected_changes.concat(detect_page_changes(welsh_content, current_content))
    detected_changes.concat(detect_condition_changes(welsh_content, current_content))

    if @form.has_draft_version
      draft_welsh = FormDocument.find_by(form_id: @form.id, tag: :draft, language: "cy")
      detected_changes.concat(detect_untranslated_content) if draft_welsh
    end

    detected_changes
  end

private

  def detect_form_field_changes(welsh_content, current_content)
    Form.mobility_attributes.filter_map do |field|
      if current_content[field].present? && welsh_content[field].blank?
        { type: :new_field, field: field.to_sym, scope: :form }
      end
    end
  end

  def detect_page_changes(welsh_content, current_content)
    changes = []
    welsh_steps = welsh_content["steps"] || []
    current_steps = current_content["steps"] || []

    welsh_step_ids = welsh_steps.map { |s| s["id"] }
    current_step_ids = current_steps.map { |s| s["id"] }

    changes.concat(detect_new_pages(current_step_ids - welsh_step_ids, current_steps))
    changes.concat(detect_deleted_pages(welsh_step_ids - current_step_ids))
    changes.concat(detect_page_field_changes(welsh_steps, current_steps))

    changes
  end

  def detect_new_pages(new_ids, current_steps)
    new_ids.filter_map do |new_id|
      step = current_steps.find { |s| s["id"] == new_id }
      page = @form.pages.find_by(external_id: new_id)
      { type: :new_page, page_id: page&.id, position: step["position"] } if page
    end
  end

  def detect_deleted_pages(deleted_ids)
    deleted_ids.map do |deleted_id|
      { type: :deleted_page, external_id: deleted_id }
    end
  end

  def detect_page_field_changes(welsh_steps, current_steps)
    changes = []

    current_steps.each do |current_step|
      welsh_step = welsh_steps.find { |s| s["id"] == current_step["id"] }
      next unless welsh_step

      page = @form.pages.find_by(external_id: current_step["id"])
      next unless page

      current_data = current_step["data"] || {}
      welsh_data = welsh_step["data"] || {}

      changes.concat(detect_new_page_fields(page, welsh_data, current_data))
      changes.concat(detect_selection_option_changes(page, welsh_data, current_data))
    end

    changes
  end

  def detect_new_page_fields(page, welsh_data, current_data)
    # Exclude question_text (always present) and answer_settings (checked separately)
    fields = Page.mobility_attributes - %w[question_text answer_settings]
    fields.filter_map do |field|
      if current_data[field].present? && welsh_data[field].blank?
        { type: :new_field, field: field.to_sym, page_id: page.id, position: page.position }
      end
    end
  end

  def detect_selection_option_changes(page, welsh_data, current_data)
    return [] if current_data["answer_settings"]&.dig("selection_options").blank?

    changes = []
    current_options = current_data["answer_settings"]["selection_options"] || []
    welsh_options = welsh_data.dig("answer_settings", "selection_options") || []

    if current_options.size > welsh_options.size
      (welsh_options.size...current_options.size).each do |index|
        changes << {
          type: :new_selection_option,
          page_id: page.id,
          position: page.position,
          option_index: index,
          option_name: current_options[index]["name"],
        }
      end
    elsif current_options.size < welsh_options.size
      changes << { type: :removed_selection_option, page_id: page.id, position: page.position }
    end

    changes
  end

  def detect_condition_changes(welsh_content, current_content)
    changes = []
    welsh_steps = welsh_content["steps"] || []
    current_steps = current_content["steps"] || []

    welsh_condition_ids = welsh_steps.flat_map { |s| (s["routing_conditions"] || []).map { |c| c["id"] } }
    current_condition_ids = current_steps.flat_map { |s| (s["routing_conditions"] || []).map { |c| c["id"] } }

    changes.concat(detect_new_conditions(current_condition_ids - welsh_condition_ids))
    changes.concat(detect_deleted_conditions(welsh_condition_ids - current_condition_ids))

    changes
  end

  def detect_new_conditions(new_ids)
    new_ids.filter_map do |new_id|
      condition = @form.conditions.find_by(id: new_id)
      next unless condition

      change = { type: :new_condition, condition_id: condition.id, page_id: condition.routing_page_id }
      change[:is_exit_page] = true if condition.is_exit_page?
      change
    end
  end

  def detect_deleted_conditions(deleted_ids)
    deleted_ids.map do |deleted_id|
      { type: :deleted_condition, condition_id: deleted_id }
    end
  end

  def detect_untranslated_content
    changes = []
    changes.concat(detect_untranslated_form_fields)
    changes.concat(detect_untranslated_page_fields)
    changes.concat(detect_untranslated_condition_fields)
    changes
  end

  def detect_untranslated_form_fields
    fields = Form.mobility_attributes - IGNORED_FORM_FIELDS
    fields.filter_map do |field|
      english_value = @form.public_send(field)
      welsh_value = @form.public_send("#{field}_cy")

      if english_value.present? && welsh_value.blank?
        { type: :untranslated_field, field: field.to_sym, scope: :form }
      end
    end
  end

  def detect_untranslated_page_fields
    changes = []
    fields = Page.mobility_attributes - IGNORED_PAGE_FIELDS

    @form.pages.each do |page|
      fields.each do |field|
        english_value = page.public_send(field)
        welsh_value = page.public_send("#{field}_cy")

        if english_value.present? && welsh_value.blank?
          changes << { type: :untranslated_field, field: field.to_sym, page_id: page.id, position: page.position }
        end
      end

      changes.concat(detect_untranslated_selection_options(page))
    end

    changes
  end

  def detect_untranslated_selection_options(page)
    return [] unless page.answer_settings.present? && page.answer_settings["selection_options"].present?

    english_options = page.answer_settings["selection_options"] || []
    welsh_options = page.answer_settings_cy&.dig("selection_options") || []

    english_options.each_with_index.filter_map do |english_option, index|
      welsh_option = welsh_options[index]
      if english_option["name"].present? && (welsh_option.nil? || welsh_option["name"].blank?)
        { type: :untranslated_option, page_id: page.id, position: page.position, option_index: index, option_name: english_option["name"] }
      end
    end
  end

  def detect_untranslated_condition_fields
    @form.conditions.flat_map do |condition|
      Condition.mobility_attributes.filter_map do |field|
        english_value = condition.public_send(field)
        welsh_value = condition.public_send("#{field}_cy")

        if english_value.present? && welsh_value.blank?
          { type: :untranslated_field, field: field.to_sym, condition_id: condition.id, scope: :condition }
        end
      end
    end
  end
end
