require "rails_helper"

describe "reports/selection_questions/radios.html.erb" do
  let(:data) do
    Report.new({
      questions: [
        {
          form_id: 1,
          form_name: "A form",
          question_text: "A question",
          is_optional: true,
          selection_options_count: 33,
        },
      ],
      count: 1,
    })
  end

  before do
    render template: "reports/selection_questions/radios", locals: { data: }
  end

  it "has expected page title" do
    expect(view.content_for(:title)).to eq "Select one only - 30 options or fewer in live forms"
  end

  it "has a back link to the selection from a list of options usage report" do
    expect(view.content_for(:back_link)).to have_link("Back to selection from a list of options usage", href: report_selection_questions_summary_path)
  end

  it "includes the form name" do
    expect(rendered).to have_link("A form", href: form_url(1))
  end

  it "includes the question text" do
    expect(rendered).to have_content("A question")
  end

  it "includes whether the options include 'None of the above'" do
    expect(rendered).to have_css("td", text: "Yes")
  end
end
