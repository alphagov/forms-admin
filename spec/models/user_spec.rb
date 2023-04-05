require "gds-sso/lint/user_spec"
require "rails_helper"

describe User do
  describe "role enum" do
    it "returns a list of roles" do
      expect(described_class.roles.keys).to eq(%w[super_admin editor])
      expect(described_class.roles.values).to eq(%w[super_admin editor])
    end
  end

  it_behaves_like "a gds-sso user class"
end
