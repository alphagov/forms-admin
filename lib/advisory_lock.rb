class AdvisoryLock
  module DSL
    def with_lock(key)
      lock_id = Zlib.crc32(key)
      connection = ActiveRecord::Base.connection

      got_lock = connection.get_advisory_lock(lock_id)
      if got_lock
        yield
      else
        puts "Skipping task, couldn't obtain lock: #{key}"
      end
    ensure
      connection.release_advisory_lock(lock_id) if got_lock
    end
  end
end
