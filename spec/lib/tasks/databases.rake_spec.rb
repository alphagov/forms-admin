require "rake"

require "rails_helper"

RSpec.describe "databases.rake" do
  before do
    Rake.application.rake_require "tasks/databases"
    Rake::Task.define_task(:environment)
  end

  describe "db:data:load" do
    subject(:task) do
      Rake::Task["db:data:load"]
        .tap(&:reenable)
    end

    context "with a filename" do
      it "loads data from the file into the primary database" do
        allow(Tasks::CustomDatabaseTasks).to receive(:load_data)

        task.invoke("data.dump")

        expect(Tasks::CustomDatabaseTasks)
          .to have_received(:load_data)
          .with(
            a_kind_of(ActiveRecord::DatabaseConfigurations::HashConfig)
              .and(having_attributes(
                     database: "forms_admin_test",
                   )),
            "data.dump",
          )
      end

      context "and file is an SQL script" do
        it "runs the SQL script" do
          expect {
            Tempfile.create(%w[test .sql]) do |f|
              f.write <<~SQL
                INSERT
                INTO users
                (name, email, provider, created_at, updated_at)
                VALUES
                ('Test User', 'sqltest@example.gov.uk', 'sql', 'now', 'now')
                ;
              SQL

              f.close

              task.invoke(f.path)
            end
          }.to change(User, :count).by(1)

          expect(User.last).to have_attributes(
            name: "Test User",
            email: "sqltest@example.gov.uk",
          )
        end
      end
    end

    context "with no arguments" do
      it "aborts with a usage message" do
        expect {
          task.invoke
        }.to raise_error(SystemExit)
          .and output(/usage: rake db:data:load/).to_stderr
      end
    end
  end

  describe "Tasks::CustomDatabaseTasks" do
    describe "#load_data" do
      context "with a database config and filename" do
        it "runs psql" do
          allow(Kernel).to receive(:system)

          db_config = instance_double(
            ActiveRecord::DatabaseConfigurations::HashConfig,
            database: "forms-admin",
            host: "localhost",
            configuration_hash: {
              username: "test",
              password: "secret",
            },
          )

          Tasks::CustomDatabaseTasks.load_data(db_config, "data.sql")

          expect(Kernel)
            .to have_received(:system)
            .with(
              a_hash_including(
                "PGHOST" => "localhost",
                "PGPASSWORD" => "secret",
                "PGUSER" => "test",
              ),
              "psql",
              any_args,
              "--file",
              "data.sql",
              "forms-admin",
              exception: true
            )
        end
      end

      context "when there is an error connecting to the database" do
        it "raises an exception" do
          db_config = instance_double(
            ActiveRecord::DatabaseConfigurations::HashConfig,
            database: "forms-admin",
            host: "not_a_postgres_server.example.com",
            configuration_hash: {
              username: "test",
              password: "secret",
            },
          )

          expect {
            Tasks::CustomDatabaseTasks.load_data(db_config, File::NULL)
          }.to raise_error(RuntimeError)
            .and output(/psql: error: /).to_stderr_from_any_process
        end
      end
    end
  end
end
