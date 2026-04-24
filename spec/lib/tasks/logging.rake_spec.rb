require "rails_helper"

RSpec.describe "Logging Rake Tasks", rakefile: false, type: :task do
  let(:rake) { Rake.application }

  before do
    my_task

    allow(rake).to receive(:top_level_tasks).and_return(%w[my_task])

    load Rails.root.join("lib/tasks/logging.rake")

    rake["environment"].invoke
  end

  context "when the task runs successfully" do
    let(:my_task) { Rake::Task.define_task(my_task: :environment) }

    it "logs when the task starts and finishes" do
      expect(Rails.logger).to receive(:info).with("Task started", hash_including(:args))

      expect(Rails.logger).to receive(:info).with("Task finished")

      rake["my_task"].invoke
    end

    it "logs the arguments passed in to the task" do
      expect(Rails.logger).to receive(:info).with("Task started", hash_including(args: %w[arg1 arg2]))

      allow(Rails.logger).to receive(:info).with("Task finished")

      rake["my_task"].invoke("arg1", "arg2")
    end
  end

  context "when the task raises an error" do
    let(:my_task) do
      Rake::Task.define_task(my_task: :environment) do
        raise StandardError, "Something went wrong"
      end
    end

    it "logs an error with the exception" do
      allow(Rails.logger).to receive(:info).with("Task started", hash_including(:args))
      expect(Rails.logger).to receive(:error).with(
        "Task failed",
        { exception: ["StandardError", "Something went wrong"] },
      )

      expect { rake["my_task"].invoke }.to raise_error(StandardError, "Something went wrong")
    end
  end

  context "when the task is aborted with SystemExit" do
    let(:my_task) do
      Rake::Task.define_task(my_task: :environment) do
        abort "exit" # rubocop:disable Rails/Exit
      end
    end

    it "logs an error with the exit message" do
      allow(Rails.logger).to receive(:info).with("Task started", hash_including(:args))
      expect(Rails.logger).to receive(:error).with("Task aborted", { exit_message: "exit" })

      expect { rake["my_task"].invoke }
        .to raise_error(SystemExit)
        .and output(/exit/).to_stderr
    end
  end
end
