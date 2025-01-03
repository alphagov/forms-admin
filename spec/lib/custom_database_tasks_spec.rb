require "rails_helper"

describe CustomDatabaseTasks do
  describe "#load_data" do
    context "with a database config and filename" do
      it "runs psql" do
        psql = instance_spy(Psql)
        allow(Psql).to receive(:new).and_return(psql)

        db_config = instance_double(
          ActiveRecord::DatabaseConfigurations::HashConfig,
        )

        described_class.load_data(db_config, "data.sql")

        expect(Psql).to have_received(:new).with(db_config)
        expect(psql).to have_received(:run).with(file: "data.sql")
      end
    end
  end

  describe "#load_data_current" do
    it "loads data into the databases for the current environment" do
      allow(described_class).to receive(:load_data)

      described_class.load_data_current("data.dump")

      expect(described_class)
        .to have_received(:load_data)
        .with(
          a_kind_of(ActiveRecord::DatabaseConfigurations::HashConfig)
            .and(having_attributes(database: "forms_admin_test")),
          "data.dump",
        )
    end
  end
end
