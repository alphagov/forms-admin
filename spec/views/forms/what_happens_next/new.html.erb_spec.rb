require "rails_helper"

describe "forms/what_happens_next/new.html.erb" do
  let(:current_form) { OpenStruct.new(id: 1, name: "Form 1", form_slug: "form-1") }
  let(:what_happens_next_form) { Forms::WhatHappensNextForm.new(form: current_form).assign_form_values }
  let(:preview_html) { "" }

  before do
    assign(:what_happens_next_form, what_happens_next_form)
    assign(:preview_html, preview_html)
    render template: "forms/what_happens_next/new"
  end

  context "when reference numbers are not enabled", feature_reference_numbers_enabled: false do
    it "does not contain text about reference numbers" do
      expect(rendered).not_to have_text(I18n.t("what_happens_next.reference_numbers"))
    end
  end

  context "when reference numbers are enabled", feature_reference_numbers_enabled: true do
    it "contains text about reference numbers" do
      expect(rendered).to have_text(I18n.t("what_happens_next.reference_numbers"))
    end
  end
end
