require "rails_helper"

class ValidatableEmailModel
  include ActiveModel::Model
  attr_accessor :email

  validates :email, email_address: true
end

RSpec.describe EmailAddressValidator do
  it_behaves_like "a field that rejects invalid email addresses" do
    let(:model) { ValidatableEmailModel.new }
    let(:attribute) { :email }
  end
end
