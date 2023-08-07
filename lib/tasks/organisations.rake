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
end
