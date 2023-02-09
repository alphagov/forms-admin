require "rails_helper"

RSpec.describe TaskListComponent::View, type: :component do
  let(:status) { nil }
  let(:active) { true }

  context "when given tasks data as an array" do
    before do
      render_inline(described_class.new(sections: [
        { title: "section a",
          rows: [
            { task_name: "task a", path: "#", status:, active: },
            { task_name: "task b", path: "#", status:, active: },
          ] },
        { title: "section 2",
          rows: [
            { task_name: "task c", path: "#", status:, active: },
            { task_name: "task d", path: "#", status:, active: },
          ] },
      ]))
    end

    it "renders both sections" do
      expect(page).to have_text("section a")
      expect(page).to have_text("section 2")
    end

    it "renders rows" do
      expect(page).to have_text("task a")
      expect(page).to have_text("task c")
    end

    it "numbers sections correctly" do
      expect(page).to have_text("1")
      expect(page).to have_text("2")
    end
  end

  context "when given an empty sections array" do
    before do
      render_inline(described_class.new(sections: []))
    end

    it "renders empty" do
      expect(page).to have_css("ol.app-task-list:empty")
    end
  end

  context "when given an empty rows array" do
    before do
      render_inline(described_class.new(sections: [
        { title: "section title", rows: [] },
      ]))
    end

    it "does not render section without rows" do
      expect(page).not_to have_text("section title")
    end
  end

  describe "summary text with count of completed tasks and total number of tasks" do
    context "when given no task completion values" do
      before do
        render_inline(described_class.new(sections: [
          { title: "section a",
            rows: [
              { task_name: "task a", path: "#", status:, active: },
            ] },
          { title: "section 2",
            rows: [
              { task_name: "task d", path: "#", status:, active: },
            ] },
        ]))
      end

      it "does not render the summary text at the top of the task list" do
        expect(page).not_to have_selector(".app-task-list__summary")
      end
    end

    context "when given task completion values" do
      before do
        render_inline(described_class.new(completed_task_count: "23", total_task_count: "34", sections: [
          { title: "section a",
            rows: [
              { task_name: "task a", path: "#", status:, active: },
            ] },
          { title: "section 2",
            rows: [
              { task_name: "task d", path: "#", status:, active: },
            ] },
        ]))
      end

      it "does render the summary text at the top of the task list" do
        expect(page).to have_selector(".app-task-list__summary", text: "You’ve completed 23 of 34 tasks.")
      end

      context "when all tasks completed then hide the summary text (i.e form is live)" do
        before do
          render_inline(described_class.new(completed_task_count: "34", total_task_count: "34", sections: [
            { title: "section a",
              rows: [
                { task_name: "task a", path: "#", status:, active: },
              ] },
            { title: "section 2",
              rows: [
                { task_name: "task d", path: "#", status:, active: },
              ] },
          ]))
        end

        it "does not render the summary text at the top of the task list" do
          expect(page).not_to have_selector(".app-task-list__summary", text: "You’ve completed 34 of 34 tasks.")
        end

        context "when draft_live_versioning feature is enabled", feature_draft_live_versioning: true do
          before do
            render_inline(described_class.new(completed_task_count: "34", total_task_count: "34", sections: [
              { title: "section a",
                rows: [
                  { task_name: "task a", path: "#", status:, active: },
                ] },
              { title: "section 2",
                rows: [
                  { task_name: "task d", path: "#", status:, active: },
                ] },
            ]))
          end

          it "does render the summary text at the top of the task list" do
            expect(page).to have_selector(".app-task-list__summary", text: "You’ve completed 34 of 34 tasks.")
          end
        end
      end
    end
  end

  describe "#render_counter?" do
    [
      { completed_task_count: nil, total_task_count: nil, feature_draft_live_versioning: false },
      { completed_task_count: nil, total_task_count: 9, feature_draft_live_versioning: false },
      { completed_task_count: 1, total_task_count: nil, feature_draft_live_versioning: false },
      { completed_task_count: nil, total_task_count: nil, feature_draft_live_versioning: true },
      { completed_task_count: nil, total_task_count: 9, feature_draft_live_versioning: true },
      { completed_task_count: 1, total_task_count: nil, feature_draft_live_versioning: true },
    ].each do |scenario|
      it "returns false if completed_task_count or total_task_count nil", feature_draft_live_versioning: scenario[:feature_draft_live_versioning] do
        task_list = described_class.new(
          completed_task_count: scenario[:completed_task_count],
          total_task_count: scenario[:total_task_count],
        )
        expect(task_list.render_counter?).to eq false
      end
    end

    [
      { completed_task_count: 0, total_task_count: 9 },
      { completed_task_count: 1, total_task_count: 9 },
      { completed_task_count: 9, total_task_count: 9 },
    ].each do |scenario|
      it "always returns true if draft_live_versioning feature is enabled", feature_draft_live_versioning: true do
        task_list = described_class.new(
          completed_task_count: scenario[:completed_task_count],
          total_task_count: scenario[:total_task_count],
        )
        expect(task_list.render_counter?).to eq true
      end
    end

    [
      { completed_task_count: 0, total_task_count: 9, result: true },
      { completed_task_count: 1, total_task_count: 9, result: true },
      { completed_task_count: 9, total_task_count: 9, result: false },
    ].each do |scenario|
      it "returns #{scenario[:result]} when there are #{scenario[:total_task_count] - scenario[:completed_task_count]} tasks not completed" do
        task_list = described_class.new(
          completed_task_count: scenario[:completed_task_count],
          total_task_count: scenario[:total_task_count],
        )
        expect(task_list.render_counter?).to eq scenario[:result]
      end
    end
  end

  describe "#get_path" do
    subject(:row) do
      TaskListComponent::Row.new(
        task_name: "some key",
        path:,
        confirm_path:,
        status:,
      )
    end

    let(:confirm_path) { -> { raise hell } }
    let(:path) { "some_path" }

    context "when the status is not completed" do
      let(:status) { :not_started }

      context "when the path provided is a string" do
        it "returns the path" do
          expect(row.get_path).to eq "some_path"
        end
      end

      context "when the path provided is callable" do
        let(:path) { -> { "some_path" } }

        it "calls the callable and returns the result" do
          expect(row.get_path).to eq "some_path"
        end
      end
    end

    context "when the status is completed" do
      let(:status) { :completed }

      context "when the confirm_path provided is a string" do
        let(:confirm_path) { "confirm_path" }

        it "returns the confirm_path" do
          expect(row.get_path).to eq "confirm_path"
        end
      end

      context "when the confirm_path provided is callable" do
        let(:confirm_path) { -> { "confirm_path" } }

        it "calls the callable and returns the result" do
          expect(row.get_path).to eq "confirm_path"
        end
      end
    end
  end
end
