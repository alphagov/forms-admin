require "rails_helper"

describe "Previewing components", type: :feature do
  before do
    login_as_standard_user
  end

  it "checks all component previews for axe errors" do
    visit "/preview/"
    links = page.all("main li > a").map { |a| a["href"] }
    links.each do |link|
      visit link
      expect_component_to_have_no_axe_errors(page)
    end
  end

  it "checks GDS Transport font is available" do
    visit "/preview/"
    font_loaded = evaluate_script("document.fonts.check('12px GDS Transport')")

    expect(font_loaded).to be true
  end
end
