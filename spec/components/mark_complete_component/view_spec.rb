require "rails_helper"

RSpec.describe MarkCompleteComponent::View, type: :component do
  let(:mark_complete_form) { Forms::MarkCompleteForm.new(form:).assign_form_values }

  let(:form) { build(:form, :with_pages, id: 2) }

  context "when the task status feature is enabled", feature_task_list_statuses: true do
    it "renders the form" do
      render_inline(described_class.new(form: mark_complete_form, path: "/"))

      expect(page.text).to have_text("Do you want to mark this task as complete?")
    end

    it "the label and hint text cna be overridden" do
      render_inline(described_class.new(form: mark_complete_form, path: "/", legend: "Have you finished editing your questions?", hint: "You can come back to your questions later"))

      expect(page.text).not_to have_text("Do you want to mark this task as complete?")
      expect(page.text).to have_text("Have you finished editing your questions?")
      expect(page.text).to have_text("You can come back to your questions later")
    end
  end

  context "when the task status feature is disabled", feature_task_list_statuses: false do
    it "renders the form" do
      render_inline(described_class.new(form: mark_complete_form, path: "/"))

      expect(page.text).not_to have_text("Do you want to mark this task as complete?")
    end
  end
end
