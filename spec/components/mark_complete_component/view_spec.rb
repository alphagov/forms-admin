require "rails_helper"

def generate_form_builder(model)
  GOVUKDesignSystemFormBuilder::FormBuilder.new(:form, model,
                                                ActionView::Base.new(ActionView::LookupContext.new(nil), {}, nil), {})
end

RSpec.describe MarkCompleteComponent::View, type: :component do
  let(:form) { build(:form, :with_pages, id: 2) }
  let(:mark_complete_input) { Forms::MarkCompleteInput.new(form:).assign_form_values }

  context "when using the generate_form option" do
    it "renders the form" do
      render_inline(described_class.new(form_model: mark_complete_input, path: "/"))

      expect(page.text).to have_text(I18n.t("mark_complete.legend"))
    end

    it "the label and hint text can be overridden" do
      render_inline(described_class.new(form_model: mark_complete_input, path: "/", legend: I18n.t("pages.index.mark_complete.legend"), hint: "You can come back to your questions later"))

      expect(page.text).not_to have_text(I18n.t("mark_complete.legend"))
      expect(page.text).to have_text(I18n.t("pages.index.mark_complete.legend"))
      expect(page.text).to have_text("You can come back to your questions later")
    end
  end

  context "when not using the generate_form option" do
    let(:form_builder) { generate_form_builder(mark_complete_input) }

    it "renders the form" do
      render_inline(described_class.new(form_builder:, generate_form: false))

      expect(page.text).to have_text(I18n.t("mark_complete.legend"))
    end

    it "the label and hint text can be overridden" do
      render_inline(described_class.new(form_builder:, generate_form: false, legend: I18n.t("pages.index.mark_complete.legend"), hint: "You can come back to your questions later"))

      expect(page.text).not_to have_text(I18n.t("mark_complete.legend"))
      expect(page.text).to have_text(I18n.t("pages.index.mark_complete.legend"))
      expect(page.text).to have_text("You can come back to your questions later")
    end
  end
end
