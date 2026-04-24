require "rake"

module RakeTaskHelpers
  class UnexpectedSystemExit < StandardError; end

  def self.included(base)
    base.class_eval do
      before do
        metadata = self.class.metadata
        rakefile = metadata.include?(:rakefile) ? metadata[:rakefile] : self.class.top_level_description

        Rake.application = Rake::Application.new
        Rake.load_rakefile("lib/tasks/#{rakefile}") if rakefile

        Rake::Task.define_task(:environment)
      end

      around do |example|
        example.run
      rescue SystemExit => e
        message = <<~MSG
          SystemExit raised but not expected in this example

          This may be because a task was invoked that calls `abort`.
          If the task was supposed to abort in this example, make
          sure to expect the SystemExit exception with
          `expect { }.to raise_error(SystemExit)`.
        MSG
        raise UnexpectedSystemExit, message, e.backtrace, cause: e
      end
    end
  end
end

RSpec.configure do |config|
  config.include RakeTaskHelpers, type: :task
end
