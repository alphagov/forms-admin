require "rails_helper"

describe "pages/conditions/new.html.erb" do
  let(:form) { build :form, id: 1 }
  let(:pages) do
    build_list :page, 3, answer_settings: OpenStruct.new(only_one_option: "true",
                                                         selection_options: [OpenStruct.new(attributes: { name: "Option 1" }),
                                                                             OpenStruct.new(attributes: { name: "Option 2" })]), form_id: 1
  end
  let(:condition_form) { Pages::ConditionsForm.new(form:, page: pages.first) }

  before do
    allow(view).to receive(:form_pages_path).and_return("/forms/1/pages")
    allow(view).to receive(:routing_page_path).and_return("/forms/1/new-condition")
    allow(view).to receive(:set_routing_page_path).with(routing_page_id: condition_form.page.id).and_return("/forms/1/new-condition?routing-page_id=#{condition_form.page.id}")
    allow(view).to receive(:create_condition_path).and_return("/forms/1/pages/1/conditions/new")
    allow(form).to receive(:qualifying_route_pages).and_return(pages)

    render template: "pages/conditions/new", locals: { condition_form: }
  end

  it "sets the correct title" do
    expect(view.content_for(:title)).to eq(t("page_titles.routing_page_new"))
  end

  it "contains page heading and sub-heading" do
    expect(rendered).to have_css("h1 .govuk-caption-l", text: form.name)
    expect(rendered).to have_css("h1.govuk-heading-l", text: t("page_titles.routing_page"))
  end

  it "has a submit button" do
    expect(rendered).to have_css("button[type='submit'].govuk-button", text: I18n.t("save_and_continue"))
  end
end
