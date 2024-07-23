namespace :default_groups do
  desc "Create all default groups"
  task create: :environment do
    Rails.logger.info "rake default_groups:create started"
    ActiveRecord::Base.transaction do
      create_trial_user_default_groups
    end
  end

  desc "Create default groups but don't commit changes"
  task create_dry_run: :environment do
    Rails.logger.info "rake default_groups:create_dry_run started"
    ActiveRecord::Base.transaction do
      create_trial_user_default_groups
      Rails.logger.info "rake default_groups:create_dry_run rollback"
      raise ActiveRecord::Rollback
    end
  end

  desc "Create default groups for organisations"
  task create_for_organisations: :environment do
    Rails.logger.info "rake default_groups:create_for_organisations started"
    ActiveRecord::Base.transaction do
    end
  end

  desc "Create default groups for organisations but don't commit changes"
  task create_for_organisations_dry_run: :environment do
    Rails.logger.info "rake default_groups:create_for_organisations_dry_run started"
    ActiveRecord::Base.transaction do
      Rails.logger.info "rake default_groups:create_for_organisations_dry_run rollback"
      raise ActiveRecord::Rollback
    end
  end

  desc "Create default groups for trial users"
  task create_for_trial_users: :environment do
    Rails.logger.info "rake default_groups:create_for_trial_users started"
    ActiveRecord::Base.transaction do
      create_trial_user_default_groups
    end
  end

  desc "Create default groups for trial users but don't commit changes"
  task create_for_trial_users_dry_run: :environment do
    Rails.logger.info "rake default_groups:create_for_trial_users_dry_run started"
    ActiveRecord::Base.transaction do
      create_trial_user_default_groups
      Rails.logger.info "rake default_groups:create_for_trial_users_dry_run rollback"
      raise ActiveRecord::Rollback
    end
  end
end

def create_trial_user_default_groups
  trial_users = User.trial.where("organisation_id IS NOT NULL AND name IS NOT NULL")
  trial_users.find_each do |user|
    DefaultGroupService.new.create_user_default_trial_group!(user)
  end
end
