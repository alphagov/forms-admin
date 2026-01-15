require "rails_helper"

describe "reports/selection_questions_summary.html.erb" do
  let(:data) do
    {
      autocomplete: {
        form_ids: Set.new([1, 2, 3, 4]),
        question_count: 444,
        optional_question_count: 111,
      },
      radios: {
        form_ids: Set.new([1, 2, 3]),
        question_count: 77,
        optional_question_count: 44,
      },
      checkboxes: {
        form_ids: Set.new([1, 2]),
        question_count: 99,
        optional_question_count: 88,
      },
      include_none_of_the_above: {
        form_ids: Set.new([1, 2]),
        question_count: 5,
        with_follow_up_question: {
          form_ids: Set.new([1]),
          question_count: 4,
          mandatory_follow_up_question_count: 3,
          optional_follow_up_question_count: 1,
        },
      },
    }
  end
  let(:tag) { "live" }

  before do
    controller.request.path_parameters[:tag] = tag
    render template: "reports/selection_questions_summary", locals: { tag:, data: }
  end

  it "has expected page title" do
    expect(view.content_for(:title)).to eq "Select from a list questions in live forms"
  end

  it "has a back link to the selection from a list of options usage report" do
    expect(view.content_for(:back_link)).to have_link("Back to feature usage", href: report_features_path(tag: :live))
  end

  it "has statistics about questions with autocomplete" do
    expect(rendered).to have_xpath "(//dl)[1]/div[1]/dt", text: "Live forms with more than 30 options"
    expect(rendered).to have_xpath "(//dl)[1]/div[1]/dd", text: "4"
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
    expect(rendered).to have_xpath "(//dl)[2]/div[1]/dd", text: "3"
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
    expect(rendered).to have_xpath "(//dl)[3]/div[1]/dd", text: "2"
    expect(rendered).to have_xpath "(//dl)[3]/div[2]/dt", text: "Number of questions"
    expect(rendered).to have_xpath "(//dl)[3]/div[2]/dd", text: "99"
    expect(rendered).to have_xpath "(//dl)[3]/div[3]/dt", text: "Questions with ‘None of the above’"
    expect(rendered).to have_xpath "(//dl)[3]/div[3]/dd", text: "88"
  end

  it "has link to questions with checkboxes report" do
    expect(rendered).to have_link("Questions where you can select one or more from up to 30 questions", href: report_selection_questions_with_checkboxes_path)
  end

  it "has statistics about questions with none of the above" do
    expect(rendered).to have_xpath "(//dl)[4]/div[1]/dt", text: "Live forms with ‘None of the above’"
    expect(rendered).to have_xpath "(//dl)[4]/div[1]/dd", text: "2"
    expect(rendered).to have_xpath "(//dl)[4]/div[2]/dt", text: "Questions with ‘None of the above’"
    expect(rendered).to have_xpath "(//dl)[4]/div[2]/dd", text: "5"
    expect(rendered).to have_xpath "(//dl)[4]/div[3]/dt", text: "Live forms with follow-up question if ‘None of the above’ is selected"
    expect(rendered).to have_xpath "(//dl)[4]/div[3]/dd", text: "1"
    expect(rendered).to have_xpath "(//dl)[4]/div[4]/dt", text: "Follow-up questions if ‘None of the above’ is selected"
    expect(rendered).to have_xpath "(//dl)[4]/div[4]/dd", text: "4"
    expect(rendered).to have_xpath "(//dl)[4]/div[5]/dt", text: "Mandatory ‘None of the above’ follow‑up questions"
    expect(rendered).to have_xpath "(//dl)[4]/div[5]/dd", text: "3"
    expect(rendered).to have_xpath "(//dl)[4]/div[6]/dt", text: "Optional ‘None of the above’ follow‑up questions"
    expect(rendered).to have_xpath "(//dl)[4]/div[6]/dd", text: "1"
  end

  it "has link to questions with none of the above report" do
    expect(rendered).to have_link("Questions with ‘None of the above’ (including follow-up questions)", href: report_selection_questions_with_none_of_the_above_path)
  end
end
