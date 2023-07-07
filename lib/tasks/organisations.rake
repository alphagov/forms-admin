require_relative "../organisations_fetcher"

namespace :organisations do
  desc "Update organisations table using data from GOV.UK"
  task fetch: :environment do
    OrganisationsFetcher.new.call
  end
end
