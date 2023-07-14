# Tests the whole page
RSpec.shared_examples "a page with no axe errors" do |_parameter|
  it "returns no axe errors" do
    expect(page).to be_axe_clean.according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
  end
end

# Tests within #main-content so only the component being previewed is being tested
RSpec.shared_examples "a component with no axe errors" do |_parameter|
  it "returns no axe errors" do
    expect(page).to be_axe_clean.within("#main-content").according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
  end
end
