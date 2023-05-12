class FormPolicy
  attr_reader :user, :form

  class UserMissingOrganisationError < StandardError; end

  class Scope
    attr_reader :user, :form, :scope

    def initialize(user, scope)
      raise UserMissingOrganisationError, "Missing required attribute organisation_slug" if user.organisation_slug.blank?

      @user = user
      @scope = scope
    end

    def resolve
      scope
        .where(org: user.organisation&.slug || user.organisation_slug)
    end
  end

  def initialize(user, form)
    raise UserMissingOrganisationError, "Missing required attribute organisation_slug" if user.organisation_slug.blank?

    @user = user
    @form = form
  end

  def can_view_form?
    users_organisation_owns_form
  end

  def can_add_page_routing_conditions?
    FeatureService.enabled?(:basic_routing) || user.super_admin?
  end

  def can_edit_page_routing_conditions?
    FeatureService.enabled?(:basic_routing)
  end

  alias_method :can_delete_page_routing_conditions?, :can_edit_page_routing_conditions?

private

  def users_organisation_owns_form
    organisation_slug = user.organisation&.slug || user.organisation_slug
    organisation_slug == form.org
  end
end
