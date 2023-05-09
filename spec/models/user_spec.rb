require "gds-sso/lint/user_spec"
require "rails_helper"

describe User do
  subject(:user) { described_class.new }

  describe "role enum" do
    it "returns a list of roles" do
      expect(described_class.roles.keys).to eq(%w[super_admin editor])
      expect(described_class.roles.values).to eq(%w[super_admin editor])
    end
  end

  it_behaves_like "a gds-sso user class"

  describe "#user_role_options" do
    before do
      allow(I18n).to receive(:t).with("users.roles.role1.name", any_args).and_return("name1")
      allow(I18n).to receive(:t).with("users.roles.role1.description", any_args).and_return("description1")

      allow(I18n).to receive(:t).with("users.roles.role2.name", any_args).and_return("name2")
      allow(I18n).to receive(:t).with("users.roles.role2.description", any_args).and_return("description2")
    end

    it "returns the correct options" do
      expect(user.user_role_options(%i[role1 role2])).to eq(
        [OpenStruct.new(label: "name1", value: :role1, description: "description1"),
         OpenStruct.new(label: "name2", value: :role2, description: "description2")],
      )
    end
  end
end
