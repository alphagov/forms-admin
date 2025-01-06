class Psql
  attr_reader :db_config

  def initialize(db_config = nil)
    raise "db_config argument is not yet supported" if db_config
  end

  def run(file: nil)
    lease_connection

    @db.transaction do
      sql = SqlConsumer.new(@db)

      if file
        File.foreach(file, ";") do |statement|
          sql.write(statement)
        end
      end

      if block_given?
        yield sql
      end
    end
  ensure
    release_connection
  end

private

  class SqlConsumer
    SEP = ";".freeze

    def initialize(db)
      @db = db
      @command_buffer = ""
    end

    def write(sql)
      @command_buffer << sql
      return unless @command_buffer.include? SEP

      next_buffer = @command_buffer.slice!(0..@command_buffer.rindex(SEP))
      next_buffer.each_line(SEP) do |statement|
        @db.exec_query(statement)
      end
    end
  end

  def lease_connection
    @db_config = ActiveRecord::Base.connection_db_config
    @db = ActiveRecord::Base.lease_connection
  end

  def release_connection
    ActiveRecord::Base.release_connection
    @db = nil
  end
end
