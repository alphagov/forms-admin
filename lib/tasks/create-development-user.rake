namespace :dev do
  desc 'Create a user to avoid GDS SSO in development - not for production'
  task :create_user => :environment do
    puts "Creating a single user if it doesn't already exist"
    User.first_or_create
  end
end
