require_relative "../advisory_lock"
require_relative "../domains_loader"

namespace :domains do
  desc "Load domain data into the database"
  task load: :environment do
    include AdvisoryLock::DSL

    with_lock("forms-admin:domains:load") do
      DomainsLoader.new.call
    end
  end
end
