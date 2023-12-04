require "rails_helper"

feature "Reset session while adding a question", type: :feature do
  let(:form) { build :form, :with_active_resource, id: 1 }
  let(:pages) { form.pages }
  let(:draft_question) { create :draft_question_for_new_page, user: editor_user, form_id: form.id }

  let(:req_headers) do
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Accept" => "application/json",
    }
  end

  let(:post_headers) do
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Content-Type" => "application/json",
    }
  end

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms/1", req_headers, form.to_json, 200
      mock.get "/api/v1/forms/1/pages", req_headers, pages.to_json, 200
    end

    login_as_editor_user
  end

  scenario "While drafting a new question the session expires" do
    given_i_am_about_to_create_a_question

    when_the_session_is_expired
    and_i_log_back_in
    and_go_to_the_last_visited_page
    # then_i_should_see_my_draft_question
  end

  def given_i_am_about_to_create_a_question
    draft_question
    visit new_question_path(form_id: form.id)
    expect(page.find("h1")).to have_text "Edit question"
  end
  
  def when_the_session_is_expired
    logout
  end
  
  def and_i_log_back_in
    login_as_editor_user
  end

  def and_go_to_the_last_visited_page
    visit new_question_path(form_id: form.id)
  end
  
  def then_i_should_see_my_draft_question
  
  end
end