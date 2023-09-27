class JsonbSerializers
  def self.dump(hash)
    hash.to_json
  end

  def self.load(hash)
    if hash.nil?
      {}
    elsif hash.is_a?(Hash) && hash.empty?
      hash
    else
      JSON.parse(hash)
    end.with_indifferent_access
  end
end
