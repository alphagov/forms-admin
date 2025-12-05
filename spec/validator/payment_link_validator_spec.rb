require "rails_helper"

class PaymentLinkModel
  include ActiveModel::Validations
  attr_accessor :payment_link

  validates :payment_link, payment_link: true
end

RSpec.describe PaymentLinkValidator do
  it_behaves_like "a payment link validator" do
    let(:model) { PaymentLinkModel.new }
    let(:attribute) { :payment_link }
  end
end
