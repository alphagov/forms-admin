require "rails_helper"

describe "reports/selection_questions/summary.html.erb" do
  let(:data) do
    Report.new({
      autocomplete: {
        form_count: 222,
        question_count: 444,
        optional_question_count: 111,
      },
      radios: {
        form_count: 33,
        question_count: 77,
        optional_question_count: 44,
      },
      checkboxes: {
        form_count: 55,
        question_count: 99,
        optional_question_count: 88,
      },
    })
  end

  before do
    render template: "reports/selection_questions/summary", locals: { data: }
  end

  it "has expected page title" do
    expect(view.content_for(:title)).to eq "Selection from a list of options in live forms"
  end

  it "has a back link to the selection from a list of options usage report" do
    expect(view.content_for(:back_link)).to have_link("Back to feature usage", href: report_features_path)
  end

  it "has statistics about questions with autocomplete" do
    page = Capybara.string(rendered.html)
    within(page.find_all(".govuk-summary-list__row").first) do
      expect(page.find_all(".govuk-summary-list__value"[0])).to have_text "234"
      expect(page.find_all(".govuk-summary-list__value"[1])).to have_text "444"
      expect(page.find_all(".govuk-summary-list__value"[2])).to have_text "111"
    end
  end

  it "has link to questions with autocomplete report" do
    expect(rendered).to have_link("View questions", href: report_selection_questions_with_autocomplete_path)
  end

  it "has statistics about questions with radio buttons" do
    page = Capybara.string(rendered.html)
    within(page.find_all(".govuk-summary-list__row")[1]) do
      expect(page.find_all(".govuk-summary-list__value"[0])).to have_text "33"
      expect(page.find_all(".govuk-summary-list__value"[1])).to have_text "77"
      expect(page.find_all(".govuk-summary-list__value"[2])).to have_text "44"
    end
  end

  it "has link to questions with radio buttons report" do
    expect(rendered).to have_link("View questions", href: report_selection_questions_with_radios_path)
  end

  it "has statistics about questions with checkboxes buttons" do
    page = Capybara.string(rendered.html)
    within(page.find_all(".govuk-summary-list__row")[1]) do
      expect(page.find_all(".govuk-summary-list__value"[0])).to have_text "55"
      expect(page.find_all(".govuk-summary-list__value"[1])).to have_text "99"
      expect(page.find_all(".govuk-summary-list__value"[2])).to have_text "88"
    end
  end

  it "has link to questions with checkboxes report" do
    expect(rendered).to have_link("View questions", href: report_selection_questions_with_checkboxes_path)
  end
end
