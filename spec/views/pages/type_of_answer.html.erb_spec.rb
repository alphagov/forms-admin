require "rails_helper"

describe "pages/type_of_answer.html.erb", type: :view do
  let(:form) { create :form }
  let(:type_of_answer_input) { build :type_of_answer_input }
  let(:page) { OpenStruct.new(routing_conditions: [], answer_type: "number") }
  let(:question_number) { 1 }
  let(:is_new_page) { true }

  before do
    # allow objects to use ids in form helper
    allow(type_of_answer_input).to receive(:persisted?).and_return(true)

    # mock the form.page_number method
    allow(form).to receive_messages(persisted?: true, page_number: question_number)

    without_partial_double_verification do
      allow(view).to receive_messages(current_form: form)
    end

    # setup instance variables
    assign(:page, page)
    assign(:type_of_answer_input, type_of_answer_input)
    assign(:type_of_answer_path, "/type-of-answer")

    render(template: "pages/type_of_answer")
  end

  it "has the correct title" do
    expect(view.content_for(:title)).to have_content("Edit question")
  end

  it "has a back link to the live form page" do
    expect(view.content_for(:back_link)).to have_link("Back", href: "/forms/#{form.id}/pages")
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
    Page::ANSWER_TYPES.each do |type|
      expect(rendered).to have_field("pages_type_of_answer_input[answer_type]", with: type)
    end
  end

  it "the answer type from the type_of_answer_input is checked" do
    selected_answer_type = type_of_answer_input.answer_type
    expect(rendered).to have_checked_field("pages_type_of_answer_input[answer_type]", with: selected_answer_type)
  end

  it "has a submit button with the correct text" do
    expect(rendered).to have_button("Continue")
  end

  it "does not display a warning about routes being deleted if answer type changes" do
    expect(rendered).not_to have_selector(".govuk-notification-banner__content")
  end

  context "when editing an existing" do
    let(:page) { OpenStruct.new(routing_conditions:, answer_type:) }
    let(:answer_type) { "selection" }
    let(:routing_conditions) { [(build :condition)] }

    it "displays a warning about routes being deleted if answer type changes" do
      expect(Capybara.string(rendered.html).find(".govuk-notification-banner__content").text(normalize_ws: true))
        .to include(Capybara.string(I18n.t("type_of_answer.routing_warning_about_change_answer_type_html", pages_link_url: form_pages_path(form)))
                        .text(normalize_ws: true))
    end

    context "when no routing conditions set" do
      let(:routing_conditions) { [] }

      it "does not display a warning about routes being deleted if answer type changes" do
        expect(rendered).not_to have_selector(".govuk-notification-banner__content")
      end
    end
  end
end
