require "rails_helper"

RSpec.describe TaskListComponent::View, type: :component do
  let(:status) { nil }
  let(:active) { true }

  context "when given tasks data as an array" do
    before do
      render_inline(described_class.new(sections: [
        { title: "section a",
          section_number: 1,
          subsection: false,
          rows: [
            { task_name: "task a", path: "#", status:, active: },
            { task_name: "task b", path: "#", status:, active: },
          ] },
        { title: "section 2",
          section_number: 2,
          subsection: false,
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
      expect(page).to have_css("div.app-task-list:empty")
    end
  end

  context "when given a section body instead of any rows" do
    before do
      render_inline(described_class.new(sections: [
        { title: "section title", body_text: "section body", section_number: 1, subsection: false },
      ]))
    end

    it "renders the section title" do
      expect(page).to have_text("section title")
    end

    it "renders the section body" do
      expect(page).to have_text("section body")
    end

    it "can render HTML in the section body" do
      render_inline(described_class.new(sections: [{
        title: "section title",
        section_number: 1,
        subsection: false,
        body_text: "section\n\nbody",
      }]))

      expect(page).to have_css("p", exact_text: "body")
    end
  end

  context "when given an empty rows array" do
    before do
      render_inline(described_class.new(sections: [
        { title: "section title", rows: [], section_number: 1, subsection: false },
      ]))
    end

    it "does not render section without rows" do
      expect(page).not_to have_text("section title")
    end
  end

  context "when given a subsection" do
    before do
      render_inline(described_class.new(sections: [
        { title: "subsection a",
          section_number: 1,
          subsection: true,
          rows: [
            { task_name: "task a", path: "#", status:, active: },
            { task_name: "task b", path: "#", status:, active: },
          ] },
      ]))
    end

    it "renders a level 3 heading with the subsection name" do
      expect(page).to have_css("h3", text: "subsection a")
    end

    it "does not show the section number" do
      expect(page).not_to have_text("1")
    end
  end

  describe "summary text with count of completed tasks and total number of tasks" do
    context "when given no task completion values" do
      before do
        render_inline(described_class.new(sections: [
          { title: "section a",
            section_number: 1,
            subsection: false,
            rows: [
              { task_name: "task a", path: "#", status:, active: },
            ] },
          { title: "section 2",
            section_number: 2,
            subsection: false,
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
            section_number: 1,
            subsection: false,
            rows: [
              { task_name: "task a", path: "#", status:, active: },
            ] },
          { title: "section 2",
            section_number: 2,
            subsection: false,
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
              section_number: 1,
              subsection: false,
              rows: [
                { task_name: "task a", path: "#", status:, active: },
              ] },
            { title: "section 2",
              section_number: 2,
              subsection: false,
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

  describe "#render_counter?" do
    [
      { completed_task_count: nil, total_task_count: nil },
      { completed_task_count: nil, total_task_count: 9 },
      { completed_task_count: 1, total_task_count: nil },
    ].each do |scenario|
      it "returns false if completed_task_count or total_task_count nil" do
        task_list = described_class.new(
          completed_task_count: scenario[:completed_task_count],
          total_task_count: scenario[:total_task_count],
        )
        expect(task_list.render_counter?).to be false
      end
    end

    [
      { completed_task_count: 0, total_task_count: 9 },
      { completed_task_count: 1, total_task_count: 9 },
      { completed_task_count: 9, total_task_count: 9 },
    ].each do |scenario|
      it "always returns true with valid task counts" do
        task_list = described_class.new(
          completed_task_count: scenario[:completed_task_count],
          total_task_count: scenario[:total_task_count],
        )
        expect(task_list.render_counter?).to be true
      end
    end

    [
      { completed_task_count: 0, total_task_count: 9, result: true },
      { completed_task_count: 1, total_task_count: 9, result: true },
      { completed_task_count: 9, total_task_count: 9, result: true },
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
        status:,
        active:,
      )
    end

    let(:path) { "some_path" }

    context "when the row is active" do
      let(:active) { true }

      it "returns the path" do
        expect(row.get_path).to eq(path)
      end
    end

    context "when the path is not nil" do
      let(:active) { false }

      it "returns the path" do
        expect(row.get_path).to be_nil
      end
    end
  end

  describe "#get_status_colour" do
    subject(:row) do
      TaskListComponent::Row.new(
        task_name: "some key",
        path: nil,
        status:,
      )
    end

    context "when status is nil" do
      let(:status) { nil }

      it "returns nil" do
        expect(row.get_status_colour).to be_nil
      end
    end

    context "when status is completed" do
      let(:status) { :completed }

      it "returns nil" do
        expect(row.get_status_colour).to be_nil
      end
    end

    context "when status is in_progress" do
      let(:status) { :in_progress }

      it "returns blue" do
        expect(row.get_status_colour).to eq("light-blue")
      end
    end

    context "when status is cannot_start" do
      let(:status) { :cannot_start }

      it "returns nil" do
        expect(row.get_status_colour).to be_nil
      end
    end

    context "when status is not_started" do
      let(:status) { :not_started }

      it "returns grey" do
        expect(row.get_status_colour).to eq("blue")
      end
    end

    context "when status is optional" do
      let(:status) { :optional }

      it "returns grey" do
        expect(row.get_status_colour).to eq("grey")
      end
    end
  end

  describe "#get_status_text" do
    subject(:row) do
      TaskListComponent::Row.new(
        task_name: "some key",
        path: nil,
        status:,
      )
    end

    context "when status is completed" do
      let(:status) { :completed }

      it "returns the translation" do
        expect(row.get_status_text).to eq(I18n.t("task_statuses.completed"))
      end
    end

    context "when status is in_progress" do
      let(:status) { :in_progress }

      it "returns the translation" do
        expect(row.get_status_text).to eq(I18n.t("task_statuses.in_progress"))
      end
    end

    context "when status is cannot_start" do
      let(:status) { :cannot_start }

      it "returns the translation" do
        expect(row.get_status_text).to eq(I18n.t("task_statuses.cannot_start"))
      end
    end

    context "when status is not_started" do
      let(:status) { :not_started }

      it "returns the translation" do
        expect(row.get_status_text).to eq(I18n.t("task_statuses.not_started"))
      end
    end

    context "when status is optional" do
      let(:status) { :optional }

      it "returns the translation" do
        expect(row.get_status_text).to eq(I18n.t("task_statuses.optional"))
      end
    end
  end

  describe "#cannot_start?" do
    subject(:row) do
      TaskListComponent::Row.new(
        task_name: "some key",
        path: nil,
        status:,
      )
    end

    context "when status is nil" do
      let(:status) { nil }

      it "returns false" do
        expect(row.cannot_start?).to be(false)
      end
    end

    context "when status is completed" do
      let(:status) { :completed }

      it "returns false" do
        expect(row.cannot_start?).to be(false)
      end
    end

    context "when status is in_progress" do
      let(:status) { :in_progress }

      it "returns false" do
        expect(row.cannot_start?).to be(false)
      end
    end

    context "when status is cannot_start" do
      let(:status) { :cannot_start }

      it "returns true" do
        expect(row.cannot_start?).to be(true)
      end
    end

    context "when status is not_started" do
      let(:status) { :not_started }

      it "returns false" do
        expect(row.cannot_start?).to be(false)
      end
    end

    context "when status is optional" do
      let(:status) { :optional }

      it "returns false" do
        expect(row.cannot_start?).to be(false)
      end
    end
  end

  describe "#get_status_tag" do
    subject(:row) do
      TaskListComponent::Row.new(
        task_name: "some key",
        path: nil,
        status:,
      )
    end

    context "when status is nil" do
      let(:status) { nil }

      it "returns nil" do
        expect(row.get_status_tag).to be_nil
      end
    end

    context "when status is completed" do
      let(:status) { :completed }

      it "returns the status as plain text" do
        expect(row.get_status_tag).to eq(row.get_status_text)
      end
    end

    context "when status is cannot_start" do
      let(:status) { :cannot_start }

      it "returns the status as plain text" do
        expect(row.get_status_tag).to eq(row.get_status_text)
      end
    end

    %i[
      in_progress
      not_started
      optional
    ].each do |status_name|
      context "when status is #{status_name}" do
        let(:status) { status_name }

        it "returns the status as a tag" do
          expect(row.get_status_tag).to eq(GovukComponent::TagComponent.new(text: row.get_status_text, colour: row.get_status_colour).call)
        end
      end
    end
  end
end
