# Based on https://github.com/rails/rails/blob/be9aa73dd72f1097be5d45a58d7912447a266bd1/activerecord/lib/active_record/tasks/postgresql_database_tasks.rb
class Psql
  attr_reader :db_config, :status

  def initialize(db_config)
    @db_config = db_config
  end

  def run(file: nil)
    args = ["--set", "ON_ERROR_STOP=1", "--single-transaction", "--quiet", "--no-psqlrc", "--output", File::NULL]
    args.concat(["--file", file]) if file
    args << db_config.database

    if block_given?
      IO.pipe do |pipe_r, pipe_w|
        pid = Kernel.spawn(psql_env, "psql", *args, in: pipe_r)
        begin
          yield pipe_w
        rescue StandardError
          Process.kill(:SIGINT, pid)
          raise
        ensure
          pipe_w.close
        end
      ensure
        if pid
          @status = Process::Status.wait(pid)
          raise "psql failed with exit #{@status.exitstatus}" if @status.success? == false
        end
      end
    else
      Kernel.system psql_env, "psql", *args, exception: true
    end
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
