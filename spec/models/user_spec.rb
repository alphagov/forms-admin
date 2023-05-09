require "gds-sso/lint/user_spec"
require "rails_helper"

describe User do
  subject(:user) { described_class.new }

  it "validates" do
    expect(user.valid?).to be true
  end

  describe "role enum" do
    it "returns a list of roles" do
      expect(described_class.roles.keys).to eq(%w[super_admin editor])
      expect(described_class.roles.values).to eq(%w[super_admin editor])
    end
  end

  it_behaves_like "a gds-sso user class"

  describe "role" do
    it "is invalid if blank" do
      user.role = nil

      expect(user.valid?).to be false
    end
  end
end
