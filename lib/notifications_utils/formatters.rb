# frozen_string_literal: true

# A copy of just the parts we need from https://github.com/alphagov/notifications-utils/blob/8b39f0006709662df689d52055867bca0a897230/notifications_utils/formatters.py

OBSCURE_ZERO_WIDTH_WHITESPACE = [
  "\u180e",  # Mongolian vowel separator
  "\u200b",  # zero width space
  "\u200c",  # zero width non-joiner
  "\u200d",  # zero width joiner
  "\u2060",  # word joiner
  "\ufeff",  # zero width non-breaking space
  "\u2028",  # line separator
  "\u2029",  # paragraph separator
].freeze

OBSCURE_FULL_WIDTH_WHITESPACE = [
  "\u00a0",  # non breaking space
  "\u202f",  # narrow no break space
].freeze

module NotificationsUtils
  module Formatters
    def strip_and_remove_obscure_whitespace(value)
      if value == ""
        # Return early to avoid making multiple, slow calls to
        # str.replace on an empty string
        return ""
      end

      (OBSCURE_ZERO_WIDTH_WHITESPACE + OBSCURE_FULL_WIDTH_WHITESPACE).each do |character|
        value = value.gsub(character, "")
      end

      value.strip
    end

    module_function :strip_and_remove_obscure_whitespace
  end
end
