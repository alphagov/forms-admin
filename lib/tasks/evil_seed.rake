require "evil_seed"

namespace :db do
  desc "Create an anonymised database dump"
  task dump: :environment do
    EvilSeed.dump("db/dump.sql")
  end

  namespace :dump do
    task s3: :environment do
      key = "forms_admin_cleaned_#{Date.today.iso8601}.sql"

      # is this the best way to get the right service?
      s3 = ActiveStorage::Blob.services.fetch(:forms_deploy)

      Tempfile.create(key) do |tempfile|
        EvilSeed.dump(tempfile)

        read_buf = File.open(tempfile.path, "r")

        s3.upload(key, read_buf)
      end
    end
  end

  desc "Restore database from SQL dump"
  task restore: [:load_config, :truncate_all] do
    db_config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).first
    ActiveRecord::Tasks::DatabaseTasks.structure_load(db_config, "db/dump.sql")
  end

  namespace :restore do
    task s3: [:load_config, :truncate_all] do
      key = "forms_admin_cleaned_#{Date.today.iso8601}.sql"

      # is this the best way to get the right service?
      s3 = ActiveStorage::Blob.services.fetch(:forms_deploy)

      key = s3.bucket.objects
              .map(&:key)
              .filter { |key| key =~ /forms_admin_cleaned_.*\.sql/ }
              .sort
              .last

      Tempfile.create(key) do |tempfile|
        write_buf = tempfile

        write_buf.write(s3.download(key))
        write_buf.close

        db_config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).first
        ActiveRecord::Tasks::DatabaseTasks.structure_load(db_config, tempfile.path)
      end

      puts "Restored database from #{key}"
    end
  end
end
