require "rails_helper"

describe "pages/type_of_answer.html.erb", type: :view do
  let(:form) { build :form, id: 1 }
  let(:type_of_answer_form) { build :type_of_answer_form, form: }
  let(:answer_types) { Page::ANSWER_TYPES }
  let(:question_number) { 1 }
  let(:is_new_page) { true }

  before do
    # allow objects to use ids in form helper
    allow(form).to receive(:persisted?).and_return(true)
    allow(type_of_answer_form).to receive(:persisted?).and_return(true)

    # mock the form.page_number method
    allow(form).to receive(:page_number).and_return(question_number)

    # mock the path helper
    without_partial_double_verification do
      allow(view).to receive(:form_forms_type_of_answer_form_path).and_return("/type-of-answer")
    end

    # setup instance variables
    assign(:form, form)
    assign(:type_of_answer_form, type_of_answer_form)
    assign(:answer_types, answer_types)

    render(template: "pages/type-of-answer")
  end

  it "has the correct title" do
    expect(view.content_for(:title)).to have_content("Edit question")
  end

  it "has a back link to the live form page" do
    expect(view.content_for(:back_link)).to have_link("Back", href: "/forms/1/pages")
  end

  it "contains the question number" do
    expect(rendered).to have_content("Question #{question_number}")
  end

  it "has the correct heading and caption" do
    expect(rendered).to have_selector("h1", text: "Question #{question_number}")
    expect(rendered).to have_selector("h1", text: "What kind of answer do you need to this question?")
  end

  it "contains a form which submits to @type_of_answer_path" do
    expect(rendered).to have_selector('form[action="/type-of-answer"]')
  end

  it "has radio buttons for each answer_type" do
    answer_types.each do |type|
      expect(rendered).to have_field("forms_type_of_answer_form[answer_type]", with: type)
    end
  end

  it "the answer type from the type_of_answer_form is checked" do
    selected_answer_type = type_of_answer_form.answer_type
    expect(rendered).to have_checked_field("forms_type_of_answer_form[answer_type]", with: selected_answer_type)
  end

  it "has a submit button with the correct text" do
    expect(rendered).to have_button("Continue")
  end
end
