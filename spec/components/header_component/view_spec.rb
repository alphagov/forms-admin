require "rails_helper"

RSpec.describe HeaderComponent::View, type: :component do
  let(:is_signed_in) { true }
  let(:list_of_users_path) { "https://forms.users" }
  let(:user_name) { "Joe Smith" }
  let(:user_profile_link) { "http://signon.dev.gov.uk" }
  let(:signout_link) { "/auth/gds/sign_out" }
  let(:hosting_environment) { OpenStruct.new(friendly_environment_name:) }
  let(:local_development) { false }
  let(:friendly_environment_name) { "production" }

  let(:header_component) do
    described_class.new(is_signed_in:,
                        list_of_users_path:,
                        user_name:,
                        user_profile_link:,
                        signout_link:,
                        hosting_environment:)
  end

  describe "default status" do
    let(:is_signed_in) { false }
    let(:list_of_users_path) { nil }
    let(:user_name) { nil }
    let(:user_profile_link) { nil }
    let(:signout_link) { nil }

    before do
      render_inline(header_component)
    end

    it "contains the service name" do
      expect(page).to have_text(I18n.t("header.product_name"))
    end

    it "does not contain the profile link" do
      expect(page).not_to have_link("Joe Smith", href: "http://signon.dev.gov.uk")
    end

    it "does not contain the sign out link" do
      expect(page).not_to have_link(I18n.t("header.sign_out"), href: "/auth/gds/sign_out")
    end
  end

  describe "logged in status" do
    let(:list_of_users_path) { nil }

    before do
      render_inline(header_component)
    end

    it "contains the service name" do
      expect(page).to have_text(I18n.t("header.product_name"))
    end

    it "contains the profile link" do
      expect(page).to have_link("Joe Smith", href: "http://signon.dev.gov.uk")
    end

    it "contains the sign out link" do
      expect(page).to have_link(I18n.t("header.sign_out"), href: "/auth/gds/sign_out")
    end
  end

  context "when no profile link or signout in passed in" do
    let(:list_of_users_path) { nil }
    let(:user_profile_link) { nil }
    let(:signout_link) { nil }

    before do
      render_inline(header_component)
    end

    it "the user name appears without a link" do
      expect(page).not_to have_link("Joe Smith")
      expect(page).to have_text("Joe Smith")
    end

    it "Signout appears without a link" do
      expect(page).not_to have_link(I18n.t("header.sign_out"))
      expect(page).to have_text(I18n.t("header.sign_out"))
    end
  end

  context "when user has permission to view list of users" do
    before do
      render_inline(header_component)
    end

    it "contains the service name" do
      expect(page).to have_text(I18n.t("header.product_name"))
    end

    it "contains the link to users pages" do
      expect(page).to have_link(I18n.t("header.users"), href: "https://forms.users")
    end

    it "contains the profile link" do
      expect(page).to have_link("Joe Smith", href: "http://signon.dev.gov.uk")
    end

    it "contains the sign out link" do
      expect(page).to have_link(I18n.t("header.sign_out"), href: "/auth/gds/sign_out")
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
