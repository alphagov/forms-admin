require "rails_helper"

describe Forms::TranslationTablePresenter do
  let(:presenter) { described_class.new }

  describe "#two_column_classes" do
    it "returns classes to render a translation table with the two column layout" do
      expect(presenter.two_column_classes).to eq(["govuk-!-margin-bottom-9", "app-form-field-table", "app-form-field-table--two-column"])
    end
  end

  describe "#three_column_classes" do
    it "returns classes to render a translation table with the three column layout" do
      expect(presenter.three_column_classes).to eq(["govuk-!-margin-bottom-9", "app-form-field-table"])
    end
  end

  describe "#two_column_headers" do
    it "returns a header row with headings for English and Welsh" do
      expect(presenter.two_column_headers).to eq({
        rows: [[
          { header: true, text: I18n.t("forms.welsh_translation.new.english_header") },
          { header: true, text: I18n.t("forms.welsh_translation.new.welsh_header") },
        ]],
      })
    end
  end

  describe "#three_column_headers" do
    it "returns a header row with a blank cell and headings for English and Welsh" do
      expect(presenter.three_column_headers).to eq({
        rows: [[
          { header: true, text: nil },
          { header: true, text: I18n.t("forms.welsh_translation.new.english_header") },
          { header: true, text: I18n.t("forms.welsh_translation.new.welsh_header") },
        ]],
      })
    end
  end
end
