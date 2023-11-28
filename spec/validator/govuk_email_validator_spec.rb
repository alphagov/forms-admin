require "rails_helper"

RSpec.describe GovukEmailValidator do
  let(:model) do
    # rubocop:disable RSpec/LeakyConstantDeclaration, Lint/ConstantDefinitionInBlock
    class ModelWithValidation
      include ActiveModel::Model
      attr_accessor :email

      validates :email, govuk_email: true
    end
    # rubocop:enable RSpec/LeakyConstantDeclaration, Lint/ConstantDefinitionInBlock
    ModelWithValidation.new
  end

  it "validates email with .gov.uk" do
    model.email = "test.gov.uk"
    expect(model).to be_valid
  end

  it "does not validate any non-govuk email" do
    model.email = "test@example.com"
    expect(model).to be_invalid
  end
end
