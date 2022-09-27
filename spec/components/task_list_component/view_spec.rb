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
