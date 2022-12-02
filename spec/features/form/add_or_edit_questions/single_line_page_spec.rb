require "rails_helper"

feature "Add/editing a single line question", type: :feature do
  let(:form) { build :form, id: 1 }
  let(:req_headers) do
    {
      "X-API-Token" => ENV["API_KEY"],
      "Accept" => "application/json",
    }
  end
  let(:post_headers) do
    {
      "X-API-Token" => ENV["API_KEY"],
      "Content-Type" => "application/json",
    }
  end

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
      mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
      mock.post "/api/v1/forms/1/pages", post_headers
    end
  end

  context "when a form has no existing pages" do
    let(:pages) { [] }

    scenario "add a single line question" do
      when_i_viewing_an_existing_form
      and_i_want_to_create_or_edit_a_page
      and_i_select_a_single_line_option
      and_i_provide_a_question_text
      and_i_save_and_create_another
    end
  end

  context "when a form has existing pages" do
    let(:pages) do
      existing_pages = []
      5.times { |id| existing_pages.push(build(:page, id:, form_id: 1)) }
      existing_pages
    end

    scenario "add a single line question" do
      when_i_viewing_an_existing_form
      and_i_want_to_create_or_edit_a_page
      and_i_can_see_a_list_of_existing_pages
      and_i_start_adding_a_new_question
      and_i_select_a_single_line_option
      and_i_provide_a_question_text
      and_i_save_and_create_another
    end
  end

private

  def when_i_viewing_an_existing_form
    visit form_path(form.id)
  end

  def and_i_want_to_create_or_edit_a_page
    click_on "Add and edit your questions"
  end

  def and_i_select_a_single_line_option
    expect(page.find("h1")).to have_text "What kind of answer do you need to this question?"
    choose "Single line of text"
    click_button "Save and continue"
    expect(page.find("h1")).to have_content "Edit question"
  end

  def and_i_provide_a_question_text
    fill_in "Question text", with: "What is your name?"
  end

  def and_i_save_and_create_another
    click_button "Save and add next question"
    expect(page.find("h1")).to have_text "What kind of answer do you need to this question?"
    expect(page).not_to have_selector("main input:checked", visible: :hidden), "Type of answer page should not have any preselected radio buttons"
  end

  def and_i_can_see_a_list_of_existing_pages
    expect(page.find("h1")).to have_text "Add and edit your questions"
    expect(page).to have_selector(".govuk-summary-list__row", count: 5)
  end

  def and_i_start_adding_a_new_question
    click_link "Add a question"
  end
end
