namespace :organisations do
  desc "Update organisations table using data from GOV.UK"
  task fetch: :environment do
    include AdvisoryLock::DSL

    Rails.logger.info("Starting organisation fetch")

    run_organisation_fetch(dry_run: false)

    Rails.logger.info("Organisation fetch complete")
  end

  desc "Dry run for update organisations table using data from GOV.UK"
  task fetch_dry_run: :environment do
    include AdvisoryLock::DSL

    Rails.logger.info("Starting dry run of organisation fetch")

    run_organisation_fetch(dry_run: true)

    Rails.logger.info("Dry run of organisation fetch complete")
  end

  desc "Add organisation that is not in GOV.UK organisation database"
  task :create, %i[name] => :environment do |_, args|
    usage_message = "usage: rails organisations:create[<name>]".freeze
    abort usage_message if args[:name].blank?

    organisation = Organisation.find_by(name: args[:name])
    abort "Organisation already exists: #{organisation.inspect}" if organisation

    organisation = Organisation.create!(
      slug: args[:name].parameterize,
      name: args[:name],
    )

    puts "Created #{organisation.inspect}"
  end

  desc "Change name of an organisation"
  task :rename, %i[old_name new_name] => :environment do |_, args|
    old_name = args[:old_name]
    new_name = args[:new_name]
    usage = "usage: rails organisations:rename[<old_name>,<new_name>]".freeze
    abort usage if old_name.blank? || new_name.blank?

    org = Organisation.find_by(name: old_name)
    abort "#{old_name} not found" if org.blank?
    abort "#{old_name} is from the GOV.UK API and should not be renamed by us" if org.govuk_content_id.present?

    org.name = new_name
    puts "Renamed org #{old_name} to #{new_name}" if org.save!
  end
end

def run_organisation_fetch(dry_run:)
  with_lock("forms-admin:organisations:fetch") do
    OrganisationsFetcher.new.call(dry_run:)
  end
end
