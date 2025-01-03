require "rake"

require "rails_helper"

RSpec.describe "databases.rake" do
  # Because we're using psql outside of ActiveRecord for this feature,
  # transactional tests don't work as expected. Instead we need to turn them
  # off temporarily so we can easily clean up after ourselves.
  self.use_transactional_tests = false

  after do
    ActiveRecord::Tasks::DatabaseTasks.truncate_all
  end

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
      it "loads data from the file into the database" do
        allow(CustomDatabaseTasks).to receive(:load_data_current)

        task.invoke("data.dump")

        expect(CustomDatabaseTasks)
          .to have_received(:load_data_current)
          .with("data.dump")
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
end
