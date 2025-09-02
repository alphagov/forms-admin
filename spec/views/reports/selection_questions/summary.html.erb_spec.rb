require "rails_helper"

describe "reports/selection_questions/summary.html.erb" do
  let(:data) do
    OpenStruct.new(
      autocomplete: OpenStruct.new(
        form_count: 222,
        question_count: 444,
        optional_question_count: 111,
      ),
      radios: OpenStruct.new(
        form_count: 33,
        question_count: 77,
        optional_question_count: 44,
      ),
      checkboxes: OpenStruct.new(
        form_count: 55,
        question_count: 99,
        optional_question_count: 88,
      ),
    )
  end

  before do
    render template: "reports/selection_questions/summary", locals: { data: }
  end

  it "has expected page title" do
    expect(view.content_for(:title)).to eq "Selection from a list of options answer type usage in live forms"
  end

  it "has a back link to the selection from a list of options usage report" do
    expect(view.content_for(:back_link)).to have_link("Back to feature usage", href: report_features_path(tag: :live))
  end

  it "has statistics about questions with autocomplete" do
    expect(rendered).to have_xpath "(//dl)[1]/div[1]/dt", text: "Live forms with more than 30 options"
    expect(rendered).to have_xpath "(//dl)[1]/div[1]/dd", text: "222"
    expect(rendered).to have_xpath "(//dl)[1]/div[2]/dt", text: "Number of questions"
    expect(rendered).to have_xpath "(//dl)[1]/div[2]/dd", text: "444"
    expect(rendered).to have_xpath "(//dl)[1]/div[3]/dt", text: "Questions with ‘None of the above’"
    expect(rendered).to have_xpath "(//dl)[1]/div[3]/dd", text: "111"
  end

  it "has link to questions with autocomplete report" do
    expect(rendered).to have_link("Questions where you can select one from over 30 options", href: report_selection_questions_with_autocomplete_path)
  end

  it "has statistics about questions with radio buttons" do
    expect(rendered).to have_xpath "(//dl)[2]/div[1]/dt", text: "Live forms with 30 options or fewer"
    expect(rendered).to have_xpath "(//dl)[2]/div[1]/dd", text: "33"
    expect(rendered).to have_xpath "(//dl)[2]/div[2]/dt", text: "Number of questions"
    expect(rendered).to have_xpath "(//dl)[2]/div[2]/dd", text: "77"
    expect(rendered).to have_xpath "(//dl)[2]/div[3]/dt", text: "Questions with ‘None of the above’"
    expect(rendered).to have_xpath "(//dl)[2]/div[3]/dd", text: "44"
  end

  it "has link to questions with radio buttons report" do
    expect(rendered).to have_link("Questions where you can select one from up to 30 options", href: report_selection_questions_with_radios_path)
  end

  it "has statistics about questions with checkboxes buttons" do
    expect(rendered).to have_xpath "(//dl)[3]/div[1]/dt", text: "Live forms using one or more"
    expect(rendered).to have_xpath "(//dl)[3]/div[1]/dd", text: "55"
    expect(rendered).to have_xpath "(//dl)[3]/div[2]/dt", text: "Number of questions"
    expect(rendered).to have_xpath "(//dl)[3]/div[2]/dd", text: "99"
    expect(rendered).to have_xpath "(//dl)[3]/div[3]/dt", text: "Questions with ‘None of the above’"
    expect(rendered).to have_xpath "(//dl)[3]/div[3]/dd", text: "88"
  end

  it "has link to questions with checkboxes report" do
    expect(rendered).to have_link("Questions where you can select one or more from up to 30 questions", href: report_selection_questions_with_checkboxes_path)
  end
end
