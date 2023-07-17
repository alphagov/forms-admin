desc "Run tests"
task test: :environment do
  sh "bundle exec rspec"
  sh "npm run test"
end
