require "rails_helper"

# stub out psql with something that lets us see what is sent to stdin
def stub_psql(cmd = "cat", method = :spawn)
  allow(Kernel).to receive(method).and_wrap_original do |spawn, *_args, **kwargs|
    spawn.call cmd, **kwargs
  end
end

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

    context "with a filename" do
      it "runs psql with the file" do
        expect(Kernel).to receive(:system) do |*args|
          expect(args).to include "--file", "test.sql"
        end

        psql.run(file: "test.sql")
      end
    end

    context "with a block" do
      it "allows IO to be sent to psql via stdin" do
        # stub out psql with something that lets us see what is sent to stdin
        stub_psql

        expect {
          psql.run do |stdin|
            stdin.write("Hello World\n")
            stdin.close
          end
        }.to output("Hello World\n").to_stdout_from_any_process
      end

      context "when the block does not close stdin" do
        it "closes stdin before returning" do
          stub_psql

          # this will hang indefinitely if stdin is not closed
          expect {
            psql.run do |stdin|
              stdin.write("Hello World\n")
            end
          }.to output("Hello World\n").to_stdout_from_any_process
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

          psql = described_class.new(db_config)

          expect {
            psql.run do |stdin|
              # nothing
            end
          }.to raise_error(RuntimeError)
            .and output(/psql: error: /).to_stderr_from_any_process
        end
      end

      context "when the block raises an exception" do
        it "tells psql to stop what it's doing" do
          stub_psql

          expect {
            begin
              psql.run do |stdin|
                stdin.write("Hello")
                raise "Something went wrong"
              end
            rescue RuntimeError
              # we're not interested in the exception for this spec
            end
          }.not_to output.to_stdout_from_any_process # cat won't echo if it's interrupted
        end

        it "sends the interrupt signal" do
          stub_psql

          begin
            psql.run do |stdin|
              raise "Something went wrong"
            end
          rescue RuntimeError
            # we're not interested in the exception for this spec
          end

          expect(psql.status).to have_attributes termsig: 2
        end

        it "re-raises the exception" do
          stub_psql

          expect {
            psql.run do |stdin|
              stdin.write("Hello")
              raise "Something went wrong"
            end
          }.to raise_error(RuntimeError, "Something went wrong")
        end
      end

      it "waits for psql to exit before returning" do
        pid = instance_spy(Integer)
        status = instance_spy(Process::Status)
        allow(Kernel).to receive(:spawn).and_return(pid)
        allow(Process::Status).to receive(:wait).and_return(status)

        psql.run do |_stdin|
          # nothing
        end

        expect(Process::Status).to have_received(:wait).with(pid)
      end
    end
  end
end
