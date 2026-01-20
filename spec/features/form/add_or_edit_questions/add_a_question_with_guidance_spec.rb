require "rails_helper"

feature "Add a question with guidance", type: :feature do
  let(:group) { create(:group, organisation: standard_user.organisation) }
  let(:form) { create :form }

  before do
    GroupForm.create!(group:, form_id: form.id)
    create(:membership, group:, user: standard_user, added_by: standard_user)

    login_as standard_user
  end

  scenario "add a question with guidance" do
    when_i_am_viewing_an_existing_form
    and_i_start_adding_a_new_question
    and_i_select_a_type_of_answer_option
    and_i_provide_a_question_text_and_hint_text
    and_i_click_the_add_guidance_button
    and_i_add_guidance
    then_i_am_returned_to_the_question_options_page_with_existing_data_retained
  end

private

  def when_i_am_viewing_an_existing_form
    visit form_path(form.id)
    expect_page_to_have_no_axe_errors(page)
  end

  def and_i_start_adding_a_new_question
    click_on "Add and edit your questions"
  end

  def and_i_select_a_type_of_answer_option
    expect(page.find("h1")).to have_text "What kind of answer do you need to this question?"
    expect_page_to_have_no_axe_errors(page)
    choose I18n.t("helpers.label.page.answer_type_options.names.number")
    click_button "Continue"
  end

  def and_i_provide_a_question_text_and_hint_text
    expect(page.find("h1")).to have_text "Edit question"
    expect_page_to_have_no_axe_errors(page)
    fill_in "Question text", with: "What is your favourite number?"
    fill_in "Hint text (optional)", with: "Please provide a number between 1 and 100."
  end

  def and_i_click_the_add_guidance_button
    click_button "Add guidance"
    expect(page.find("h1")).to have_text "Add guidance"
    expect_page_to_have_no_axe_errors(page)
  end

  def and_i_add_guidance
    fill_in "Give your page a heading", with: "A page heading"
    fill_in "Add guidance text", with: "Some helpful guidance text."
    click_button "Continue"
  end

  def then_i_am_returned_to_the_question_options_page_with_existing_data_retained
    expect(page.find("h1")).to have_text "Edit question"
    expect(find_field("pages_question_input[question_text]").value).to eq "What is your favourite number?"
    expect(find_field("pages_question_input[hint_text]").value).to eq "Please provide a number between 1 and 100."
    expect(page).to have_content "A page heading"
    expect(page).to have_content "Some helpful guidance text."
  end
end
