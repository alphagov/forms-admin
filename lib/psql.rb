# Based on https://github.com/rails/rails/blob/be9aa73dd72f1097be5d45a58d7912447a266bd1/activerecord/lib/active_record/tasks/postgresql_database_tasks.rb
class Psql
  attr_reader :db_config

  def initialize(db_config)
    @db_config = db_config
  end

  def run(file:)
    args = ["--set", "ON_ERROR_STOP=1", "--quiet", "--no-psqlrc", "--output", File::NULL, "--file", file, db_config.database]
    Kernel.system psql_env, "psql", *args, exception: true
  end

private

  def psql_env
    configuration_hash = db_config.configuration_hash
    {}.tap do |env|
      env["PGHOST"]         = db_config.host                        if db_config.host
      env["PGPORT"]         = configuration_hash[:port].to_s        if configuration_hash[:port]
      env["PGPASSWORD"]     = configuration_hash[:password].to_s    if configuration_hash[:password]
      env["PGUSER"]         = configuration_hash[:username].to_s    if configuration_hash[:username]
      env["PGSSLMODE"]      = configuration_hash[:sslmode].to_s     if configuration_hash[:sslmode]
      env["PGSSLCERT"]      = configuration_hash[:sslcert].to_s     if configuration_hash[:sslcert]
      env["PGSSLKEY"]       = configuration_hash[:sslkey].to_s      if configuration_hash[:sslkey]
      env["PGSSLROOTCERT"]  = configuration_hash[:sslrootcert].to_s if configuration_hash[:sslrootcert]
    end
  end
end
