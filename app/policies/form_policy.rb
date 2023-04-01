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

private

  def users_organisation_owns_form
    user.organisation_slug == form.org
  end
end
