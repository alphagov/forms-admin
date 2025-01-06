require "rails_helper"

RSpec.describe Psql do
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

    let(:db_config) { nil }

    it "runs sql scripts" do
      file = Tempfile.create(%w[psql_spec .sql])

      file.write(valid_sql)
      file.close

      expect {
        psql.run(file: file.path)
      }.to change_database
    end

    context "with a filename" do
      it "runs psql with the file" do
        expect(File).to receive(:foreach) do |*args|
          expect(args).to start_with "test.sql"
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
          }.to raise_error(ActiveRecord::StatementInvalid, /not_a_column/)
        end

        it "does not make any changes to the database" do
          expect {
            expect {
              psql.run(file: file.path)
            }.to raise_error(ActiveRecord::StatementInvalid, /not_a_column/)
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
          }.to raise_error(ActiveRecord::StatementInvalid, /not_a_column/)
        end

        it "does not make any changes to the database" do
          expect {
            expect {
              psql.run do |stdin|
                stdin.write(valid_sql)
                stdin.write(invalid_sql)
              end
            }.to raise_error(ActiveRecord::StatementInvalid, /not_a_column/)
          }.not_to change_database
        end
      end
    end
  end
end
