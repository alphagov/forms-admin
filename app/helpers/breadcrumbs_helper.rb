# frozen_string_literal: true

module BreadcrumbsHelper
  # rubocop: disable Rails/HelperInstanceVariable
  def groups_breadcrumb
    if @current_user&.organisation_id == @group&.organisation_id
      { t("page_titles.group_index") => groups_path }
    else
      {
        t("breadcrumbs.organisation_groups", organisation_name: @group.organisation.name) =>
          groups_path(search: { organisation_id: @group.organisation_id }),
      }
    end
  end
  # rubocop: enable Rails/HelperInstanceVariable
end
