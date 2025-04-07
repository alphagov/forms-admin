# frozen_string_literal: true

module BreadcrumbsHelper
  # rubocop: disable Rails/HelperInstanceVariable
  def groups_breadcrumb(organisation = nil)
    if organisation.nil? || @current_user&.organisation_id == organisation&.id
      { t("page_titles.group_index") => groups_path }
    else
      {
        t("breadcrumbs.organisation_groups", organisation_name: organisation.name) =>
          groups_path(search: { organisation_id: organisation.id }),
      }
    end
  end
  # rubocop: enable Rails/HelperInstanceVariable

  def group_breadcrumb(group)
    { group.name => group_path(group.external_id) }
  end

  def form_breadcrumb(form)
    { form.name => form_path(form.id) }
  end

  def live_form_breadcrumb(form)
    { form.name => live_form_path(form.id) }
  end

  def archived_form_breadcrumb(form)
    { form.name => archived_form_path(form.id) }
  end
end
