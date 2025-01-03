module CustomDatabaseTasks
  class << self
    def load_data(db_config, file)
      Psql.new(db_config).run(file:)
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
