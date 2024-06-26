namespace :trial_users do
  desc "Output summary data about each trial user as newline-delimited JSON"
  task summary: :environment do
    puts(Summarizer.new.summarize.to_json)
  end
end

class Summarizer
  def summarize
    total_trial_users = User.trial.count
    trial_users_with_org_and_name = User.trial.where("organisation_id IS NOT NULL AND name IS NOT NULL")
    total_trial_users_with_org_and_name = trial_users_with_org_and_name.count
    total_trial_users_without_org_or_name = User.trial.where("organisation_id IS NULL OR name IS NULL").count

    total_forms_to_add_to_groups = 0
    total_trial_user_groups = 0
    total_trial_users_with_groups = 0
    total_trial_user_groups_to_create = 0
    total_trial_users_with_forms = 0
    total_trial_users_with_org_name_and_forms = 0
    total_trial_users_with_default_group = 0
    total_trial_user_forms_in_groups = 0
    total_trial_user_forms_not_in_group = 0
    trial_user_forms_not_in_default_group = Set.new

    group_form_ids = Set.new(GroupForm.pluck(:form_id))

    User.trial.find_each do |trial_user|
      with_org_and_name = trial_user.organisation.present? && trial_user.name.present?
      forms = Form.where(creator_id: trial_user.id)
      trial_user_form_ids = Set.new(forms.map(&:id))
      default_group = Group.find_by(creator: trial_user, name: "#{trial_user.name}’s trial group", status: :trial)
      default_group_form_ids = GroupForm.where(group: default_group).pluck(:form_id).to_set

      forms_without_group = trial_user_form_ids - group_form_ids

      total_trial_users_with_forms += 1 if forms.present?
      total_trial_user_groups_to_create += 1 if with_org_and_name && forms_without_group.present?
      total_trial_users_with_org_name_and_forms += 1 if with_org_and_name && forms.present?
      total_trial_users_with_default_group += 1 if default_group.present?
      total_forms_to_add_to_groups += forms_without_group.count if with_org_and_name
      total_trial_user_forms_in_groups += (trial_user_form_ids.count - forms_without_group.count)
      total_trial_user_forms_not_in_group += forms_without_group.count
      trial_user_forms_not_in_default_group += (trial_user_form_ids - forms_without_group - default_group_form_ids)

      total_trial_user_groups += Group.where(creator_id: trial_user.id).count
      total_trial_users_with_groups += 1 if Group.where(creator_id: trial_user.id).present?
    end

    {
      total_forms_to_add_to_groups:,
      total_trial_user_forms_in_groups:,
      total_trial_user_forms_not_in_group:,
      total_trial_user_groups:,
      total_trial_user_groups_to_create:,
      total_trial_users:,
      total_trial_users_with_forms:,
      total_trial_users_with_groups:,
      total_trial_users_with_org_and_name:,
      total_trial_users_with_org_name_and_forms:,
      total_trial_users_without_org_or_name:,
      trial_user_forms_not_in_default_group: trial_user_forms_not_in_default_group.to_a,
    }
  end
end
