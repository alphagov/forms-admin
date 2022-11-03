require "rails_helper"

RSpec.describe MarkCompleteComponent::View, type: :component do
  let(:mark_complete_form) { Forms::MarkCompleteForm.new(form:).assign_form_values }

  context "when the form has pages" do
    let(:form) { build(:form, :with_pages, id: 2) }

    context "when the task status feature is enabled" do
      before do
        allow(FeatureService).to receive(:enabled?).with(:task_list_statuses).and_return(true)
      end

      it "renders the form" do
        render_inline(described_class.new(form.pages, mark_complete_form, "/"))

        expect(page.text).to have_text("Have you finished editing your questions?")
      end
    end

    context "when the task status feature is disabled" do
      before do
        allow(FeatureService).to receive(:enabled?).with(:task_list_statuses).and_return(false)
      end

      it "renders the form" do
        render_inline(described_class.new(form.pages, mark_complete_form, "/"))

        expect(page.text).not_to have_text("Have you finished editing your questions?")
      end
    end
  end

  context "when the form has no pages" do
    let(:form) { build(:form, :new_form, id: 2) }

    it "does not render the form" do
      render_inline(described_class.new(form.pages, mark_complete_form, "/"))
      expect(page).not_to have_text("Have you finished editing your questions?")
    end
  end
end
