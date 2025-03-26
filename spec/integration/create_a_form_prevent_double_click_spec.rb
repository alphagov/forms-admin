require "rails_helper"

RSpec.describe "Create a form", type: :feature do
  let(:form) { build :form, id: 1, name: "Test form", created_at: Faker::Time.backward }
  let(:unwanted_form) { build :form, id: 2, name: "Test form", created_at: form.created_at + 0.1 }

  let(:group) do
    group = create :group, name: "Test group", creator: user
    create :membership, group:, user:, added_by: user
    group
  end

  let(:user) { standard_user }

  before :context do # rubocop: disable RSpec/BeforeAfterAll
    Capybara.current_driver = Settings.show_browser_during_tests ? :cuprite : :cuprite_headless
    page.driver.browser.disable_javascript
  end

  after :context do # rubocop: disable RSpec/BeforeAfterAll
    Capybara.use_default_driver
  end

  before do
    login_as user

    allow(FormRepository).to receive(:create!).and_return form, unwanted_form
    allow(FormRepository).to receive(:find).with(form_id: 1).and_return form
    allow(FormRepository).to receive(:find).with(form_id: "1").and_return form
    allow(FormRepository).to receive(:find).with(form_id: 2).and_return unwanted_form
    allow(FormRepository).to receive(:find).with(form_id: "2").and_return unwanted_form
    allow(FormRepository).to receive(:pages).and_return([])
  end

  it "creates one form" do
    visit group_path(group)
    click_on "Create a form"

    fill_in "What’s the name of your form?", with: form.name

    double_click find_button("Save and continue")

    expect(page).to have_title form.name

    expect(FormRepository).to have_received(:create!).once
    expect(GroupForm.count).to eq 1
  end

  # Element#double_click isn't working as expected in Ferrum
  # (see https://github.com/rubycdp/ferrum/issues/529),
  # so we need to reimplement it
  def double_click(element)
    node = element.base.node
    mouse = node.page.mouse

    x, y = node.find_position
    mouse.move(x:, y:)
    mouse.down
    mouse.up
    sleep(0.05)
    mouse.down
    mouse.up

    element
  end
end
