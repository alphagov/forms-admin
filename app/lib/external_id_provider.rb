class ExternalIdProvider
  def self.generate_id
    SecureRandom.base58(8)
  end
end
