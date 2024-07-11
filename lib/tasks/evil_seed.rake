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

      # buffer = IO::Buffer.new(10.megabyte)
      # IO::pipe do |read_buf, write_buf|; end
      # StringIO.open do |buffer|; end

      # read_buf, write_buf = PipeWithSizeHint.create(512.kilobytes)
      # read_buf = write_buf = CompatBuffer.new(10.megabyte)

      # upload = Thread.new { s3.upload(key, read_buf) }
      # upload.join

      Tempfile.create(key) do |tempfile|
        # read_buf = write_buf.clone
        write_buf = tempfile

        EvilSeed.dump(write_buf)

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

class CompatBuffer < IO::Buffer
  def close
    free
  end
end

class PipeWithSizeHint
  attr_reader :size
  delegate :read, :rewind, :write, :close, to: :@io

  def initialize(io, size_hint)
    @io = io
    @size = size_hint
  end

  def self.create(size_hint)
    r, w = IO.pipe

    return self.new(r, size_hint), self.new(w, size_hint)
  end
end

class BufferedPipe
  def initialize
    @buffer = StringIO.new
    @read_io, @write_io = IO.pipe
  end
end
