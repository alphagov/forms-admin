class FormPolicy
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
end
