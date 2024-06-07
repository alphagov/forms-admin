namespace :default_groups do
  desc "Create default groups for organisations"
  task create: :environment do
    Rails.logger.info "rake default_groups:create started"
    ActiveRecord::Base.transaction do
      create_default_groups
    end
  end

  desc "Create default groups for organisations but don't commit changes"
  task create_dry_run: :environment do
    Rails.logger.info "rake default_groups:create_dry_run started"
    ActiveRecord::Base.transaction do
      create_default_groups
      Rails.logger.info "rake default_groups:create_dry_run rollback"
      raise ActiveRecord::Rollback
    end
  end
end

def create_default_groups
  Organisation.joins(:users).where(users: { role: :editor }).distinct.each do |org|
    Rails.logger.info "default_group: organisation #{org.name}"

    if org.default_group.nil?
      status = org.mou_signatures.present? ? :active : :trial
      org.create_default_group!(name: "#{org.name} forms", organisation: org, status:)
      org.save!
      Rails.logger.info "default_group: created #{org.default_group.name}, with status #{org.default_group.status}"
    end

    org.users.editor.each do |editor|
      org.default_group.memberships.find_or_create_by!(user: editor) do |membership|
        membership.role = :editor
        membership.added_by = editor
        Rails.logger.info "default_group: added user #{editor.email}"
      end
    end

    # Form is not an activerecord object so find_each is not right here
    # rubocop:disable Rails/FindEach
    Form.where(organisation_id: org.id).each do |form|
      GroupForm.find_or_create_by!(form_id: form.id) do |group_form|
        Rails.logger.info "default_group: added form to default group #{form.name}"
        group_form.group = org.default_group
      end
    end
    # rubocop:enable Rails/FindEach

    Rails.logger.info "rake default_groups finished"
  end
end
