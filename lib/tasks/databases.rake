namespace :db do
  namespace :data do
    desc "Load data into database from file"
    task :load, %i[filename] => :environment do |_, args|
      usage_message = "usage: rake db:data:load[<filename>]".freeze
      abort usage_message if args[:filename].blank?

      CustomDatabaseTasks.load_data_current(args[:filename])
    end
  end
end
