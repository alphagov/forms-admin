module CustomDatabaseTasks
  class << self
    def load_data(db_config, file)
      if file.start_with?("s3://")
        load_data_from_s3(db_config, file)
      else
        Psql.new.run(file:)
      end
    end

    def load_data_from_s3(_db_config, s3_uri)
      s3 = Aws::S3::Client.new
      s3_uri = URI(s3_uri)
      s3_object = {
        bucket: s3_uri.host,
        key: s3_uri.path[1..],
      }

      Psql.new.run do |stdin|
        s3.get_object(s3_object) do |chunk, _headers|
          stdin.write chunk
        end
      end
    end

    def load_data_current(file)
      each_current_configuration do |db_config|
        load_data(db_config, file)
      end
    end

  private

    def each_current_configuration(&block)
      ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).each(&block)
    end
  end
end
