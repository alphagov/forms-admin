# This service reverts a draft form to a form_document with a given tag,
# effectively discarding all draft changes
class RevertDraftFormService
  attr_reader :form

  # A list of attributes on the Form model that should be not be reverted
  FORM_ATTRIBUTES_TO_PRESERVE = %i[id created_at updated_at creator_id].freeze
  ATTRIBUTES_TO_EXCLUDE = Form::ATTRIBUTES_NOT_IN_FORM_DOCUMENT + FORM_ATTRIBUTES_TO_PRESERVE

  def initialize(form)
    @form = form
  end

  # Discards draft changes by reverting the form and its associations
  # to the state of the form_document with the given tag
  # Returns true on success, false on failure
  def revert_draft_from_form_document(tag)
    # Return early if there's no draft to discard
    form_document = FormDocument.find_by(form_id: form.id, tag:, language: "en")
    return false if form_document.blank?

    form_document_content = form_document.content

    ActiveRecord::Base.transaction do
      revert_form_attributes(form_document_content)
      revert_pages_and_nested_associations(form_document_content["steps"])

      form.delete_draft_from_live_form
      form.save!
    end

    true
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Failed to discard draft for form #{form.id}: #{e.message}")
    false
  end

private

  # revert the top-level attributes of the Form object
  def revert_form_attributes(form_document_content)
    attributes_to_update = Form.attribute_names - ATTRIBUTES_TO_EXCLUDE.map(&:to_s)

    form.assign_attributes(form_document_content.slice(*attributes_to_update))
  end

  # synchronize all pages and their nested routing conditions
  def revert_pages_and_nested_associations(steps_data)
    # ensure we have the latest version of pages
    form.pages.reload

    form_document_step_ids = steps_data.pluck("id")

    # delete any pages on the form that are not present in the form_document version
    form.pages.where.not(id: form_document_step_ids).destroy_all

    # iterate through the form_document steps data to create or update pages using the original ids
    steps_data.each do |step_data|
      page = form.pages.find_or_initialize_by(id: step_data["id"])

      assign_page_attributes(page, step_data)
      synchronize_routing_conditions_for_page(page, step_data["routing_conditions"] || [])

      page.save!
    end
  end

  # steps in a form_document store the page attributes under "data"
  def assign_page_attributes(page, step_data)
    page_data = step_data["data"]
    page.assign_attributes(
      position: step_data["position"],
      question_text: page_data["question_text"],
      hint_text: page_data["hint_text"],
      answer_type: page_data["answer_type"],
      is_optional: page_data["is_optional"],
      answer_settings: page_data["answer_settings"],
      page_heading: page_data["page_heading"],
      guidance_markdown: page_data["guidance_markdown"],
      is_repeatable: page_data["is_repeatable"],
    )
  end

  # synchronize the routing conditions for a single page
  def synchronize_routing_conditions_for_page(page, conditions_data)
    form_document_condition_ids = conditions_data.pluck("id")

    # remove any conditions which have been added to the draft but are not in the form_document data
    page.routing_conditions.where.not(id: form_document_condition_ids).destroy_all

    # create or update conditions from the form_document data
    conditions_data.each do |condition_data|
      condition = Condition.find_by(id: condition_data["id"]) ||
        page.routing_conditions.build(id: condition_data["id"])

      condition.assign_attributes(
        answer_value: condition_data["answer_value"],
        routing_page_id: condition_data["routing_page_id"],
        check_page_id: condition_data["check_page_id"],
        goto_page_id: condition_data["goto_page_id"],
      )
      condition.save!
    end
  end
end
