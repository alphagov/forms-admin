require "rails_helper"

RSpec.describe HeaderComponent::View, type: :component do
  describe "default status" do
    before do
      render_inline(described_class.new(nil))
    end

    it "contains the service name" do
      expect(page).to have_text("Forms")
    end

    it "does not contain the profile link" do
      expect(page).not_to have_link("A User", href: "http://signon.dev.gov.uk/users/123456/edit")
    end

    it "does not contain the sign out link" do
      expect(page).not_to have_link("Sign out", href: "/auth/gds/sign_out")
    end
  end

  describe "logged in status" do
    before do
      current_user = OpenStruct.new(name: "A User", uid: "123456")
      render_inline(described_class.new(current_user))
    end

    it "contains the service name" do
      expect(page).to have_text("Forms")
    end

    it "contains the profile link" do
      expect(page).to have_link("A User", href: "http://signon.dev.gov.uk/users/123456/edit")
    end

    it "contains the sign out link" do
      expect(page).to have_link("Sign out", href: "/auth/gds/sign_out")
    end
  end
end
