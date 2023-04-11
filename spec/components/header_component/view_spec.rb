require "rails_helper"

RSpec.describe HeaderComponent::View, type: :component do
  describe "default status" do
    before do
      render_inline(described_class.new(is_signed_in: false,
                                        list_of_users_path: nil,
                                        user_name: nil,
                                        user_profile_link: nil,
                                        signout_link: nil))
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
    before do
      render_inline(described_class.new(is_signed_in: true,
                                        list_of_users_path: nil,
                                        user_name: "Joe Smith",
                                        user_profile_link: "http://signon.dev.gov.uk",
                                        signout_link: "/auth/gds/sign_out"))
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
    before do
      render_inline(described_class.new(is_signed_in: true,
                                        list_of_users_path: nil,
                                        user_name: "Joe Smith",
                                        user_profile_link: nil,
                                        signout_link: nil))
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
      render_inline(described_class.new(is_signed_in: true,
                                        list_of_users_path: "https://forms.users",
                                        user_name: "Joe Smith",
                                        user_profile_link: "http://signon.dev.gov.uk",
                                        signout_link: "/auth/gds/sign_out"))
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
end
