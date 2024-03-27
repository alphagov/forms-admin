require "rails_helper"

describe "Assign an organisation to a user with a signed MOU", type: :feature do
  let(:user) { create :user, :with_trial_role, name: "Test User", organisation: nil }
  let(:mou_signature) { create(:mou_signature, user:, organisation: nil, created_at: Time.zone.parse("September 1, 2023")) }
  let(:organisation) { create :organisation }

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms?creator_id=#{super_admin_user.id}", headers, [].to_json, 200
    end

    mou_signature
  end

  it "a logged in user can sign an MOU" do
    login_as_super_admin_user
    when_i_visit_the_mou_index_page
    then_i_can_see_the_mou_page
    then_i_see_the_mou_with_no_organisation
    then_i_visit_the_users_page
    then_i_update_the_user_organisation
    when_i_visit_the_mou_index_page
    then_i_can_see_the_mou_page
    then_i_see_the_mou_with_organisation
  end

private

  def when_i_visit_the_mou_index_page
    visit mou_signatures_path
  end

  def then_i_can_see_the_mou_page
    expect(page).to have_text "Memorandum of Understanding agreements"
  end

  def then_i_see_the_mou_with_no_organisation
    expect(page).to have_text mou_signature.user.name
    expect(page).to have_text mou_signature.user.email
    expect(page).to have_text "No organisation"
  end

  def then_i_visit_the_users_page
    click_link mou_signature.user.email
  end

  def then_i_update_the_user_organisation
    fill_in "Organisation", with: "#{organisation.name}\n"
    click_button "Save"
  end

  def then_i_see_the_mou_with_organisation
    expect(page).to have_text mou_signature.user.name
    expect(page).to have_text organisation.name
  end
end
