class DefaultGroupService
  # the purpose of this is to create default groups for users that have created forms before groups existed, but were
  # not members of an organisation. Until we are satisfied all forms that should belong in a group are in a group, this
  # code should be retained
  def create_user_default_trial_group!(user)
    return unless user.name.present? && user.organisation.present?

    forms = Form.where(creator_id: user.id).to_h { [_1.id, _1] }
    form_ids = forms.keys
    group_form_ids = GroupForm.where(form_id: form_ids).pluck(:form_id)
    not_group_form_ids = form_ids.to_set - group_form_ids

    if not_group_form_ids.blank?
      Rails.logger.info "DefaultGroupService: User '#{user.name}' does not have any forms not in groups, skipping creating default group"
      return
    end

    Rails.logger.info "DefaultGroupService: User '#{user.name}' default group creation starting"

    default_trial_group_name = "#{user.name}’s trial group"
    begin
      default_trial_group = Group.find_or_create_by!(
        creator_id: user.id,
        name: default_trial_group_name,
        organisation_id: user.organisation_id,
        status: :trial,
      ) do |new_group|
        Rails.logger.info "DefaultGroupService: Created default group '#{new_group.name}', with creator '#{new_group.creator.email}'"
      end
    rescue ActiveRecord::RecordInvalid => e
      raise unless e.record.errors.added? :name, :taken, value: default_trial_group_name
      raise if Group.exists?(creator_id: user.id, name: default_trial_group_name, organisation_id: user.organisation_id, status: :active)

      # Make a number to disambiguate, starting at 2, and increasing by one if that is also already taken
      attempt ||= 1
      attempt += 1
      raise "DefaultGroupService: Aborted, possible infinite loop" if attempt > 100

      default_trial_group_name = "#{user.name} #{attempt}’s trial group"
      Rails.logger.info "DefaultGroupService: Group with name '#{e.record.name}' already exists, trying with '#{default_trial_group_name}"
      retry
    end

    default_trial_group.memberships.find_or_create_by!(
      user:,
      role: :group_admin,
      added_by: user,
    ) do |new_membership|
      Rails.logger.info "DefaultGroupService: Added user '#{new_membership.user.email}' with '#{new_membership.role}' role to default group '#{default_trial_group.name}'"
    end

    not_group_form_ids.each do |form_id|
      GroupForm.find_or_create_by!(form_id:) do |group_form|
        Rails.logger.info "DefaultGroupService: Added form '#{forms[form_id].name}' to default group '#{default_trial_group.name}'"
        group_form.group = default_trial_group
      end
    end

    Rails.logger.info "DefaultGroupService: User '#{user.name}' default group creation finished"

    default_trial_group
  end
end
