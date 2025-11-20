class FormCopyService
  DONT_COPY = %i[created_at updated_at submission_email].freeze
  TO_EXCLUDE = Form::ATTRIBUTES_NOT_IN_FORM_DOCUMENT + DONT_COPY

  def initialize(form)
    @form = form
    @copied_form = Form.new
  end

  def copy(tag: "draft")
    form_doc = FormDocument.find_by(form_id: @form.id, tag:, language: @form.language)
    return false if form_doc.blank?

    content = form_doc.content

    ActiveRecord::Base.transaction do
      copy_attributes(content)
      prepend_name

      copy_pages(content["steps"])
      copy_routing_conditions(content["steps"])
      copy_group

      @copied_form.save!
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error("Failed to copy form #{@form.id}: #{e.message}")
      raise
    end

    Rails.logger.info("Form #{@form.id} copied to #{@copied_form.id} by #{@form.creator_id}")

    @copied_form
  end

private

  def attributes_to_copy
    Form.attribute_names - TO_EXCLUDE.map(&:to_s)
  end

  def copy_attributes(content)
    @copied_form.assign_attributes(content.slice(*attributes_to_copy))
  end

  def copy_pages(steps)
    return if steps.blank?

    steps.each do |step|
      page = @copied_form.pages.build
      copy_page_attributes(page, step)
      page.save!
    end
  end

  def copy_page_attributes(page, step)
    data = step["data"]
    page.assign_attributes(
      position: step["position"],
      question_text: data["question_text"],
      hint_text: data["hint_text"],
      answer_type: data["answer_type"],
      is_optional: data["is_optional"],
      answer_settings: data["answer_settings"],
      page_heading: data["page_heading"],
      guidance_markdown: data["guidance_markdown"],
      is_repeatable: data["is_repeatable"],
    )
  end

  def prepend_name
    @copied_form.name = "Copy of #{@form.name}"
  end

  def copy_routing_conditions(steps)
    return if steps.blank?

    # Build a mapping from old page IDs to new page objects
    page_id_mapping = steps.each_with_index.to_h { |step, index| [step["id"], @copied_form.pages[index]] }

    # Extract all conditions from all steps and copy them
    all_conditions_data = steps.flat_map { |step| step["routing_conditions"] || [] }
    all_conditions_data.each do |condition_data|
      copy_condition(condition_data, page_id_mapping)
    end
  end

  def copy_condition(condition_data, page_id_mapping)
    condition = Condition.new(
      routing_page: page_id_mapping[condition_data["routing_page_id"]],
      check_page: page_id_mapping[condition_data["check_page_id"]],
      goto_page: page_id_mapping[condition_data["goto_page_id"]],
      answer_value: condition_data["answer_value"],
      skip_to_end: condition_data["skip_to_end"] || false,
      exit_page_heading: condition_data["exit_page_heading"],
      exit_page_markdown: condition_data["exit_page_markdown"],
    )

    condition.save!
  end

  def copy_group
    GroupForm.create(group_id: @form.group.id, form_id: @copied_form.id)
  end
end
