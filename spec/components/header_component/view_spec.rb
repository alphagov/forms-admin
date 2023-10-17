require "rails_helper"

RSpec.describe HeaderComponent::View, type: :component do
  let(:navigation_items) { [] }
  let(:local_development) { false }
  let(:friendly_environment_name) { "production" }
  let(:hosting_environment) { OpenStruct.new(friendly_environment_name:) }

  let(:header_component) do
    described_class.new(navigation_items:, hosting_environment:)
  end

  describe "default status" do
    before do
      render_inline(header_component)
    end

    it "contains the service name" do
      expect(page).to have_text(I18n.t("header.product_name"))
    end

    context "when given navigation_items" do
      let(:navigation_items) do
        [
          { text: "Mous", href: "/mous" },
          { text: "Users", href: "/users" },
          { text: "Joe Smith", href: "/profile" },
          { text: "Sign out", href: "/signout" },
        ]
      end

      it "displays navigation items" do
        expect(page).to have_css(".govuk-header__navigation-list li", count: 4)
        expect(page).to have_link("Mous", href: "/mous")
        expect(page).to have_link("Users", href: "/users")
        expect(page).to have_link("Joe Smith", href: "/profile")
        expect(page).to have_link("Sign out", href: "/signout")
      end
    end
  end

  context "when user is on a non-production environment" do
    let(:friendly_environment_name) { "local" }

    before do
      render_inline(header_component)
    end

    it "contains the service name with tag" do
      expect(page).to have_text("#{I18n.t('header.product_name')} local")
    end
  end

  context "when user is on the production environment" do
    let(:local_development) { false }
    let(:friendly_environment_name) { "production" }

    before do
      render_inline(header_component)
    end

    it "contains the service name without tag" do
      expect(page).to have_text(I18n.t("header.product_name"))
      expect(page).not_to have_css(".govuk_tag", text: "production")
    end
  end

  describe "#environment_name" do
    it "returns the friendly environment name" do
      expect(header_component.environment_name).to eq(hosting_environment.friendly_environment_name)
    end
  end

  describe "#app_header_class_for_environment" do
    [
      { colour: "pink" },
      { colour: "green" },
      { colour: "yellow" },
      { colour: "blue" },
    ].each do |scenario|
      context "when colour_for_environment is #{scenario[:colour]}" do
        before do
          allow(header_component).to receive(:colour_for_environment).and_return(scenario[:colour])
        end

        it "returns 'app-header--#{scenario[:colour]}'" do
          expect(header_component.app_header_class_for_environment).to eq("app-header--#{scenario[:colour]}")
        end
      end
    end
  end

  describe "#colour_for_environment" do
    [
      { friendly_environment_name: "local", expected_result: "pink" },
      { friendly_environment_name: "development", expected_result: "green" },
      { friendly_environment_name: "staging", expected_result: "yellow" },
      { friendly_environment_name: "production", expected_result: "blue" },
      { friendly_environment_name: "user research", expected_result: "blue" },
    ].each do |scenario|
      context "when environment_name is #{scenario[:friendly_environment_name]}" do
        let(:friendly_environment_name) { scenario[:friendly_environment_name] }

        it "returns '#{scenario[:expected_result]}'" do
          expect(header_component.colour_for_environment).to eq(scenario[:expected_result])
        end
      end
    end
  end

  describe "#environment_tag" do
    context "when environment_name is production" do
      let(:friendly_environment_name) { "production" }

      it "returns a govuk tag component with the appropriate text and colour" do
        expect(header_component.environment_tag).to eq({ body: nil })
      end
    end

    [
      { friendly_environment_name: "local", colour_for_environment: "pink" },
      { friendly_environment_name: "development", colour_for_environment: "green" },
      { friendly_environment_name: "staging", colour_for_environment: "yellow" },
      { friendly_environment_name: "user-research", colour_for_environment: "blue" },
    ].each do |scenario|
      context "when environment_name is #{scenario[:friendly_environment_name]}" do
        let(:friendly_environment_name) { scenario[:friendly_environment_name] }

        it "returns a govuk tag component with the appropriate text and colour" do
          expect(header_component.environment_tag).to have_attributes(text: scenario[:friendly_environment_name], colour: scenario[:colour_for_environment])
        end
      end
    end
  end
end
