require "rails_helper"

RSpec.describe HeaderComponent::View, type: :component do
  let(:local_development) { false }
  let(:friendly_environment_name) { "production" }
  let(:hosting_environment) { OpenStruct.new(friendly_environment_name:) }

  let(:header_component) do
    described_class.new(hosting_environment:)
  end

  describe "default status" do
    before do
      render_inline(header_component)
    end

    it "contains the service name" do
      expect(page).to have_text(I18n.t("header.product_name"))
    end

    it "has a full width border" do
      expect(page).to have_css(".govuk-header--full-width-border")
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
      { colour: "turquoise" },
      { colour: "yellow" },
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

    context "when colour_for_environment is blue" do
      before do
        allow(header_component).to receive(:colour_for_environment).and_return("blue")
      end

      it "returns nil because the header is already blue" do
        expect(header_component.app_header_class_for_environment).to be_nil
      end
    end
  end

  describe "#colour_for_environment" do
    [
      { friendly_environment_name: "Local", expected_result: "pink" },
      { friendly_environment_name: "Development", expected_result: "turquoise" },
      { friendly_environment_name: "Staging", expected_result: "yellow" },
      { friendly_environment_name: "Production", expected_result: "blue" },
      { friendly_environment_name: "User research", expected_result: "blue" },
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
    context "when environment_name is Production" do
      let(:friendly_environment_name) { I18n.t("environment_names.production") }

      it "returns a govuk tag component with the appropriate text and colour" do
        expect(header_component.environment_tag).to eq({ body: nil })
      end
    end

    [
      { friendly_environment_name: "Local", colour_for_environment: "pink" },
      { friendly_environment_name: "Development", colour_for_environment: "turquoise" },
      { friendly_environment_name: "Staging", colour_for_environment: "yellow" },
      { friendly_environment_name: "User research", colour_for_environment: "blue" },
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
