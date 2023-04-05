require "gds-sso/lint/user_spec"
require "rails_helper"

describe User do
  describe "role enum" do
    it "returns a list of roles" do
      expect(User.roles.keys).to eq(%w[super_admin editor])
      expect(User.roles.values).to eq(%w[super_admin editor])
    end
  end

  it_behaves_like "a gds-sso user class"
end
