require "rails_helper"

describe "Check which MOUs have been signed", type: :feature do
  let(:user) { super_admin_user }
  let(:mou_signatures) do
    [create(:mou_signature, created_at: Time.zone.parse("October 12, 2023")),
     create(:mou_signature, created_at: Time.zone.parse("September 1, 2023"))]
  end

  before do
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/api/v1/forms?organisation_id=#{user.organisation.id}", headers, [].to_json, 200
      mock.get "/api/v1/forms?creator_id=#{user.id}", headers, [].to_json, 200
    end

    mou_signatures

    login_as_super_admin_user
  end

  it "super_admin's can see the MOUs page" do
    then_i_click_on_the_mou_link
    then_i_can_see_the_mou_page
    then_i_can_see_the_mou_list
  end

private

  def then_i_can_see_the_mou_list
    expect(page).to have_text mou_signatures.first.organisation.name
    expect(page).to have_link mou_signatures.first.user.email
    expect(page).to have_text mou_signatures.first.user.name
    expect(page).to have_text "October 12, 2023"

    expect(page).to have_text mou_signatures.second.organisation.name
    expect(page).to have_link mou_signatures.second.user.email
    expect(page).to have_text mou_signatures.second.user.name
    expect(page).to have_text "September 01, 2023"
  end

  def then_i_click_on_the_mou_link
    visit root_path
    click_link("MOUs")
  end

  def then_i_can_see_the_mou_page
    expect(page).to have_text "Memorandum of Understanding agreements"
  end
end
