class FormPolicy
  attr_reader :user, :form

  class UserMissingOrganisationError < StandardError; end

  class Scope
    attr_reader :user, :form, :scope

    def initialize(user, scope)
      raise UserMissingOrganisationError, "Missing required attribute organisation_id" if user.organisation.blank?

      @user = user
      @scope = scope
    end

    def resolve
      scope
        .where(org: user.organisation.slug)
    end
  end

  def initialize(user, form)
    raise UserMissingOrganisationError, "Missing required attribute organisation_id" if user.organisation.blank?

    @user = user
    @form = form
  end

  def can_view_form?
    users_organisation_owns_form
  end

  def can_add_page_routing_conditions?
    form_has_two_or_more_pages = form.pages.length >= 2
    form_has_qualifying_pages = form.qualifying_route_pages.any?

    FeatureService.enabled?(:basic_routing) && form_has_two_or_more_pages && form_has_qualifying_pages
  end

  def can_edit_page_routing_conditions?
    FeatureService.enabled?(:basic_routing)
  end

  alias_method :can_delete_page_routing_conditions?, :can_edit_page_routing_conditions?

private

  def users_organisation_owns_form
    user.organisation.slug == form.org
  end
end
