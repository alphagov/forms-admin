class FormPolicy
  attr_reader :user, :form

  class UserMissingOrganisationError < StandardError; end

  class Scope
    attr_reader :user, :form, :scope

    def initialize(user, scope)
      raise UserMissingOrganisationError, "Missing required attribute organisation_id" unless user.organisation_valid?

      @user = user
      @scope = scope
    end

    def resolve
      if user.trial?
        scope.where(creator_id: user.id)
      elsif user.super_admin?
        scope
      else
        scope
          .where(organisation_id: user.organisation.id)
      end
    end
  end

  def initialize(user, form)
    raise UserMissingOrganisationError, "Missing required attribute organisation_id" unless user.organisation_valid?

    @user = user
    @form = form
  end

  def can_view_form?
    return true if user.super_admin?

    if groups_enabled?
      return user.groups.include?(form.group) || user.is_organisations_admin?(form.group.organisation)
    end

    # TODO: Remove these checks in cleanup after groups feature
    if user.trial?
      user_is_form_creator
    else
      users_organisation_owns_form
    end
  end

  alias_method :delete?, :can_view_form?
  alias_method :destroy?, :delete?

  def can_change_form_submission_email?
    return false if user.trial? && !groups_enabled?

    can_view_form?
  end

  def can_add_page_routing_conditions?
    form_has_two_or_more_pages = form.pages.length >= 2
    form_has_qualifying_pages = form.qualifying_route_pages.any?

    form_has_two_or_more_pages && form_has_qualifying_pages
  end

  def can_make_form_live?
    # TODO: we should remove the check the form is within a group when we remove the feature flag
    return can_change_form_submission_email? unless groups_enabled?
    return can_change_form_submission_email? if form.group.active? && can_administer_group?

    false
  end

  def can_administer_group?
    user.super_admin? || user.is_organisations_admin?(form.group.organisation) || user.is_group_admin?(form.group)
  end

private

  def groups_enabled?
    FeatureService.new(user).enabled?(:groups) && form.group.present?
  end

  def user_is_form_creator
    form.creator_id.present? ? user.id == form.creator_id : false
  end

  def users_organisation_owns_form
    user.organisation.present? ? user.organisation_id == form.organisation_id : false
  end
end
