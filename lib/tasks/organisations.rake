require_relative "../advisory_lock"
require_relative "../organisations_fetcher"

namespace :organisations do
  desc "Update organisations table using data from GOV.UK"
  task fetch: :environment do
    include AdvisoryLock::DSL

    with_lock("forms-admin:organisations:fetch") do
      OrganisationsFetcher.new.call
    end
  end

  desc "Dump organisations in format usable by ActiveHash"
  task dump: :environment do
    include AdvisoryLock::DSL

    with_lock("forms-admin:organisations:fetch") do
      File.open("tmp/organisations.yml", "w") do |f|
        organisations = Organisation.all
          .as_json(only: %i[govuk_content_id slug name])
          .map(&:compact)

        f.write(organisations.to_yaml)

        puts "wrote #{organisations.length} records into #{f.path}"
      end
    end
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
