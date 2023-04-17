class FormPolicy
  attr_reader :user, :form

  class Scope
    attr_reader :user, :form, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
        .where(org: user.organisation_slug)
    end
  end

  def initialize(user, form)
    @user = user
    @form = form
  end

  def can_view_form?
    users_organisation_owns_form
  end

  def can_add_page_routing_conditions?
    FeatureService.enabled?(:basic_routing) || user.super_admin?
  end

private

  def users_organisation_owns_form
    user.organisation_slug == form.org
  end
end
