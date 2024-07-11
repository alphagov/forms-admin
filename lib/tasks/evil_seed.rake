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

      Tempfile.create(key) do |write_buf|
        # read_buf = write_buf.clone

        EvilSeed.dump(write_buf)

        read_buf = File.open(write_buf.path, "r")

        s3.upload(key, read_buf)
      end
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
