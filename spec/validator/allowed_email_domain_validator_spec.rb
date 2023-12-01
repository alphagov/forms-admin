require "rails_helper"

class Validatable
  include ActiveModel::Validations
  attr_accessor :email

  validates :email, allowed_email_domain: true
end

class ValidatableWithCurrentUser
  include ActiveModel::Model
  attr_accessor :current_user, :email

  validates :email, allowed_email_domain: true
end

RSpec.describe AllowedEmailDomainValidator do
  let(:model) { Validatable.new }

  it "validates email with .gov.uk" do
    model.email = "test.gov.uk"
    expect(model).to be_valid
  end

  it "does not validate any non-govuk email" do
    model.email = "test@example.com"
    expect(model).to be_invalid
  end

  context "with model with current_user" do
    let(:current_user) { build :user, email: "a@ogd.example" }
    let(:model) { ValidatableWithCurrentUser.new(current_user:) }

    it "validates email with .gov.uk" do
      model.email = "inbox@test.gov.uk"
      expect(model).to be_valid
    end

    it "does not validate any non-govuk email" do
      model.email = "test@example.com"
      expect(model).to be_invalid
    end

    it "validates email with same domain as user" do
      model.email = "b@ogd.example"
      expect(model).to be_valid
    end

    it "does not validate email with different domain to user" do
      model.email = "b@dogd.example"
      expect(model).to be_invalid
    end
  end
end
