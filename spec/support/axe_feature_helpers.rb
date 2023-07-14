module AxeFeatureHelpers
  def expect_page_to_have_no_axe_errors(page)
    expect(page).to be_axe_clean.according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
  end
end

RSpec.configure do |config|
  config.include AxeFeatureHelpers, type: :feature
end
