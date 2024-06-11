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
    total_trial_users_with_org_name_and_forms = 0
    total_trial_user_forms_in_groups = 0

    trial_users_with_org_and_name.find_each do |trial_user|
      forms = Form.where(creator_id: trial_user.id)
      forms_without_group = Set.new(forms.map(&:id)) - GroupForm.pluck(:form_id)

      total_trial_user_groups_to_create += 1 if forms_without_group.present?
      total_trial_users_with_org_name_and_forms += 1 if forms.present?
      total_forms_to_add_to_groups += forms_without_group.count
      total_trial_user_forms_in_groups += forms.count - forms_without_group.count

      total_trial_user_groups += Group.where(creator_id: trial_user.id).count
      total_trial_users_with_groups += 1 if Group.where(creator_id: trial_user.id).present?
    end

    {
      total_trial_users:,
      total_trial_users_with_org_and_name:,
      total_trial_users_without_org_or_name:,
      total_forms_to_add_to_groups:,
      total_trial_user_groups_to_create:,
      total_trial_user_groups:,
      total_trial_users_with_org_name_and_forms:,
      total_trial_users_with_groups:,
      total_trial_user_forms_in_groups:,
    }
  end
end
