require "rails_helper"

RSpec.describe Psql do
  describe "#run" do
    subject(:psql) { described_class.new(db_config) }

    let(:db_config) do
      instance_double(
        ActiveRecord::DatabaseConfigurations::HashConfig,
        database: "forms-admin",
        host: "localhost",
        configuration_hash: {
          username: "test",
          password: "secret",
        },
      )
    end

    it "runs psql" do
      allow(Kernel).to receive(:system)

      psql.run(file: "script.sql")

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
          "script.sql",
          "forms-admin",
          exception: true,
        )
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

        psql = described_class.new(db_config)

        expect {
          psql.run(file: File::NULL)
        }.to raise_error(RuntimeError)
          .and output(/psql: error: /).to_stderr_from_any_process
      end
    end
  end
end
