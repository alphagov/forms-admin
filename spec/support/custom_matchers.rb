# eq_string matcher includes special characters in the output on failure for easier debugging
RSpec::Matchers.define :eq_string do |expected|
  match do |string|
    unless expected.respond_to?(:dump)
      raise TypeError, "expected for eq_string should be a string"
    end

    string == expected
  end

  failure_message do |string|
    got = string.respond_to?(:dump) ? string.dump : string.inspect
    "expected: #{expected.dump}\n     got: #{got}"
  end

  failure_message_when_negated do |string|
    got = string.respond_to?(:dump) ? string.dump : string.inspect
    "expected: value != #{expected.dump}\n     got: #{got}"
  end
end
