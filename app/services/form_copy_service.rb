class FormCopyService
  def initialize(form)
    @form = form
    @page_ids_map = @form.pages.pluck(:id).product([{}]).to_h
  end

  def copy
    copied_form = @form.dup
    copied_form.state = "draft"
    copied_form.external_id = nil
    copied_form.submission_email = nil
    copied_form.group_form = GroupForm.new(group_id: @form.group.id, form_id: copied_form.id)
    copied_form.save!

    copy_pages(copied_form)
    copy_conditions_for_all_pages

    copied_form.reload
    FormDocumentSyncService.update_draft_form_document(copied_form)
    copied_form
  end

  def copy_pages(copied_form)
    @form.pages.each do |page|
      copied_page = page.dup
      copied_page.form = copied_form
      copied_form.pages << copied_page
      copied_page.save!

      @page_ids_map[page.id] = copied_page.id
    end
  end

  def copy_conditions_for_all_pages
    @form.pages.each do |page|
      copied_page = Page.find(@page_ids_map[page.id])
      copy_conditions(page, copied_page, @page_ids_map)
    end
  end

  def copy_conditions(page, copied_page, page_ids_map)
    page.routing_conditions.each_with_index do |condition, _index|
      copied_condition = condition.dup

      copied_condition.routing_page_id = page_ids_map[condition.routing_page_id] if condition.routing_page_id.present?
      copied_condition.goto_page_id = page_ids_map[condition.goto_page_id] if condition.goto_page_id.present?
      copied_condition.check_page_id = page_ids_map[condition.check_page_id] if condition.check_page_id.present?

      copied_condition.routing_page = copied_page
      copied_page.routing_conditions << copied_condition

      copied_condition.save!
    end
  end
end
