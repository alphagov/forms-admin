class EmailParameterFilterProc
  # email regexp from regular-expressions.info/email.html
  EMAIL_REGEXP = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i

  def self.new(mask: ActiveSupport::ParameterFilter::FILTERED)
    @mask = mask

    proc do |_key, value|
      value.is_a?(String) ? value.gsub!(EMAIL_REGEXP, @mask) : value
    end
  end
end
