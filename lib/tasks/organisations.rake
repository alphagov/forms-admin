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
end

def run_organisation_fetch(dry_run:)
  with_lock("forms-admin:organisations:fetch") do
    OrganisationsFetcher.new.call(dry_run:)
  end
end
