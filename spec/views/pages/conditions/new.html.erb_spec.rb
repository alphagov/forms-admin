require "rails_helper"

describe "pages/conditions/new.html.erb" do
  let(:form) { build :form, id: 1 }
  let(:pages) do
    build_list(:page, 3) do |page, i|
      page.id = i
      page.form_id = 1
      page.answer_settings = OpenStruct.new(only_one_option: "true", selection_options: [OpenStruct.new(attributes: { name: "Option 1" }), OpenStruct.new(attributes: { name: "Option 2" })])
      page.next_page = i + 1 if i < 3
    end
  end
  let(:condition_input) { Pages::ConditionsInput.new(form:, page: pages.first) }

  before do
    pages.first.position = 1
    allow(FormRepository).to receive(:pages).and_return(pages)
    allow(view).to receive(:set_routing_page_path).with(routing_page_id: condition_input.page.id).and_return("/forms/1/new-condition?routing-page_id=#{condition_input.page.id}")
    allow(view).to receive_messages(form_pages_path: "/forms/1/pages", routing_page_path: "/forms/1/new-condition", create_condition_path: "/forms/1/pages/1/conditions/new")
    allow(form).to receive(:qualifying_route_pages).and_return(pages)

    render template: "pages/conditions/new", locals: { condition_input: }
  end

  it "sets the correct title" do
    expect(view.content_for(:title)).to eq "Add route 1: Select an answer and where to skip to"
  end

  it "contains page heading and sub-heading" do
    expect(rendered).to have_css("h1 .govuk-caption-l", text: "Question 1’s routes")
    expect(rendered).to have_css("h1.govuk-heading-l", text: "Add route 1")
  end

  it "has a submit button" do
    expect(rendered).to have_css("button[type='submit'].govuk-button", text: I18n.t("save_and_continue"))
  end
end
