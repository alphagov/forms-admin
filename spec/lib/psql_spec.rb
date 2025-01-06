require "rails_helper"

RSpec.describe Psql do
  # Because we're using psql outside of ActiveRecord for this feature,
  # transactional tests don't work as expected. Instead we need to turn them
  # off temporarily so we can easily clean up after ourselves.
  self.use_transactional_tests = false

  before do
    db.create_table :test_psql do |t|
      t.column :value, :string
    end
  end

  after do
    db.drop_table :test_psql

    ActiveRecord::Base.release_connection
  end

  let(:valid_sql) { "INSERT INTO test_psql (value) VALUES ('#{Faker::Alphanumeric.alphanumeric}');\n" }
  let(:invalid_sql) { "INSERT INTO test_psql (not_a_column) VALUES (#{Faker::Number.number});\n" }

  let(:change_database) { change { db.select_value("SELECT count(*) FROM test_psql;") } }

  let(:db) { ActiveRecord::Base.lease_connection }

  describe "#run" do
    subject(:psql) { described_class.new(db_config) }

    let(:db_config) do
      ActiveRecord::Base.connection_db_config
    end

    it "runs psql" do
      file = Tempfile.create(%w[psql_spec .sql])

      file.write(valid_sql)
      file.close

      expect {
        psql.run(file: file.path)
      }.to change_database
    end

    context "when there is an error connecting to the database" do
      let(:db_config) do
        instance_double(
          ActiveRecord::DatabaseConfigurations::HashConfig,
          database: "forms-admin",
          host: "not_a_postgres_server.example.com",
          configuration_hash: {
            username: "test",
            password: "secret",
          },
        )
      end

      it "raises an exception" do
        expect {
          psql.run(file: File::NULL)
        }.to raise_error(RuntimeError, /psql/)
          .and output(/psql: error: /).to_stderr_from_any_process
      end
    end

    context "with a database configuration" do
      let(:db_config) do
        instance_double(
          ActiveRecord::DatabaseConfigurations::HashConfig,
          database: "my_database",
          host: "server.example.test",
          configuration_hash: {
            username: "test",
            password: "secret",
          },
        )
      end

      it "connects to the database" do
        expect(Kernel).to receive(:system) do |env, _cmd, *args, **_options|
          expect(env).to include(
            "PGHOST" => "server.example.test",
            "PGPASSWORD" => "secret",
            "PGUSER" => "test",
          )

          expect(args).to end_with "my_database"
        end

        psql.run(file: "script.sql")
      end
    end

    context "with a filename" do
      it "runs psql with the file" do
        expect(Kernel).to receive(:system) do |*args|
          expect(args).to include "--file", "test.sql"
        end

        psql.run(file: "test.sql")
      end

      context "when there is an error in the SQL" do
        let(:file) { Tempfile.create(%w[psql_spec .sql]) }

        before do
          file.write(valid_sql)
          file.write(invalid_sql)
          file.close
        end

        it "raises an exception" do
          expect {
            psql.run(file: file.path)
          }.to raise_error(RuntimeError, /psql/)
            .and output.to_stderr_from_any_process
        end

        it "does not make any changes to the database" do
          expect {
            expect {
              psql.run(file: file.path)
            }.to raise_error(RuntimeError, /psql/)
              .and output.to_stderr_from_any_process
          }.not_to change_database
        end
      end
    end

    context "with a block" do
      it "allows IO to be sent to psql via stdin" do
        expect {
          psql.run do |stdin|
            stdin.write(valid_sql)
          end
        }.to change_database
      end

      context "when the block raises an exception" do
        it "re-raises the exception" do
          expect {
            psql.run do |stdin|
              stdin.write(valid_sql)
              raise "Something went wrong"
            end
          }.to raise_error(RuntimeError, "Something went wrong")
        end

        it "does not make any changes to the database" do
          expect {
            expect {
              psql.run do |stdin|
                stdin.write(valid_sql)
                raise "Something went wrong"
              end
            }.to raise_error(RuntimeError, "Something went wrong")
          }.not_to change_database
        end
      end

      context "when there is an error in the SQL" do
        it "raises an exception" do
          expect {
            psql.run do |stdin|
              stdin.write(valid_sql)
              stdin.write(invalid_sql)
            end
          }.to raise_error(RuntimeError, /psql/)
            .and output.to_stderr_from_any_process
        end

        it "does not make any changes to the database" do
          expect {
            expect {
              psql.run do |stdin|
                stdin.write(valid_sql)
                stdin.write(invalid_sql)
              end
            }.to raise_error(RuntimeError, /psql/)
              .and output.to_stderr_from_any_process
          }.not_to change_database
        end
      end

      it "waits for psql to exit before returning" do
        psql.run do |_stdin|
          # nothing
        end

        expect(psql.status).to be_exited
      end
    end
  end
end
