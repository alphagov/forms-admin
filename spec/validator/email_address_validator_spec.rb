require "rails_helper"

class EmailAddressModel
  include ActiveModel::Model
  attr_accessor :email

  validates :email, email_address: true
end

RSpec.describe EmailAddressValidator do
  it_behaves_like "a field that rejects invalid email addresses" do
    let(:model) { EmailAddressModel.new }
    let(:attribute) { :email }
  end
end
