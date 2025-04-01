# frozen_string_literal: true

module BreadcrumbsHelper
  # rubocop: disable Rails/HelperInstanceVariable
  def groups_breadcrumb
    own_organisation = @current_user.organisation_id == @group.organisation_id
    organisations_groups_text = own_organisation ? "Your groups" : "#{@group.organisation.name}’s groups"
    search = own_organisation ? nil : { organisation_id: @group.organisation_id }

    { organisations_groups_text => groups_path(search:) }
  end
  # rubocop: enable Rails/HelperInstanceVariable
end
