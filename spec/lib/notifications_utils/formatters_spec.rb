require "spec_helper"
require "./spec/support/custom_matchers"

require "notifications_utils/formatters"

RSpec.describe NotificationsUtils::Formatters do
  include described_class

  describe ".strip_and_remove_obscure_whitespace" do
    [
      "notifications-email",
      "  \tnotifications-email \x0c ",
      "\rn\u200coti\u200dfi\u200bcati\u2060ons-\u180eemai\ufeffl\ufeff",
    ].each do |value|
      it "removes obscure whitespace" do
        expect(strip_and_remove_obscure_whitespace(value)).to eq_string "notifications-email"
      end
    end

    it "only removes normal whitespace from ends" do
      sentence = "   words \n over multiple lines with \ttabs\t   "
      expect(strip_and_remove_obscure_whitespace(sentence)).to eq_string "words \n over multiple lines with \ttabs"
    end
  end
end
