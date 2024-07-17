class FormService
  include Rails.application.routes.url_helpers

  def initialize(form)
    @form = form
  end

  def path_for_state
    return live_form_path(@form.id) if @form.is_live?
    return archived_form_path(@form.id) if @form.is_archived?

    form_path(@form.id)
  end

  def add_to_default_group!(current_user)
    if current_user.trial?
      add_to_trial_user_default_group!(current_user)
    end
  end

private

  def add_to_trial_user_default_group!(current_user)
    default_trial_group = Group.find_or_create_by!(
      creator_id: current_user.id,
      name: "#{current_user.name}’s trial group",
      organisation_id: current_user.organisation_id,
      status: :trial,
    )
    default_trial_group.memberships.find_or_create_by!(
      user: current_user,
      role: :group_admin,
      added_by: current_user,
    )
    GroupForm.create!(
      group: default_trial_group,
      form_id: @form.id,
    )
  end
end
