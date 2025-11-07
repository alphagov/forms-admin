class ExternalIdProvider
  MAX_RETRIES = 5

  def self.generate_id
    SecureRandom.base58(8)
  end

  def self.generate_unique_id_for(record_class, column: :external_id)
    unless record_class.respond_to?(:exists?)
      raise ArgumentError, "record_class must be an ActiveRecord class"
    end

    MAX_RETRIES.times do
      id = generate_id
      return id unless record_class.exists?(column => id)
    end

    raise "Unable to generate unique #{column} for #{record_class}"
  end
end
