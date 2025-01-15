require "rails_helper"

describe "pages/secondary_skip/edit.html.erb" do
  let(:form) { build :form, id: 1, pages: [page] }
  let(:page) do
    build(:page,
          :with_selections_settings,
          id: 1,
          position: 1,
          answer_settings: DataStruct.new(
            only_one_option: true,
            selection_options: [
              OpenStruct.new(attributes: { name: "Option 1" }),
              OpenStruct.new(attributes: { name: "Option 2" }),
            ],
          ),
          routing_conditions: [
            build(:condition, id: 1, routing_page_id: 1, check_page_id: 1, answer_value: "Yes", goto_page_id: 2, skip_to_end: false),
          ])
  end

  let(:secondary_skip_input) { Pages::SecondarySkipInput.new(form:, page:) }

  before do
    assign(:secondary_skip_input, secondary_skip_input)
    render template: "pages/secondary_skip/edit"
  end

  it "has the correct title" do
    expect(view.content_for(:title)).to have_content(I18n.t("page_titles.new_secondary_skip", route_index: 2))
  end

  it "has the correct back link" do
    expect(view.content_for(:back_link)).to have_link(I18n.t("secondary_skip.new.back", page_position: 1), href: show_routes_path(form_id: 1, page_id: 1))
  end

  it "has the correct heading and caption" do
    expect(rendered).to have_selector("h1", text: "Question 1’s routes")
    expect(rendered).to have_selector("h1", text: I18n.t("page_titles.new_secondary_skip", route_index: 2))
  end
end
