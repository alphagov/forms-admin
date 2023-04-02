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

  def show?
    users_organisation_owns_form
  end

  alias_method :mark_pages_section_completed?, :show?
  alias_method :can_make_live?, :show?
  alias_method :delete_form?, :show?
  alias_method :create?, :show?
  alias_method :edit?, :create?
  alias_method :update?, :edit?

private

  def users_organisation_owns_form
    user.organisation_slug == form.org
  end
end
