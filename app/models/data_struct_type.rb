class DataStructType < ActiveModel::Type::Value
  def type
    :jsonb
  end

  # rubocop:disable Style/RescueModifier
  def cast_value(value)
    case value
    when String
      decoded = ActiveSupport::JSON.decode(value) rescue nil
      DataStruct.recursive_new(decoded) unless decoded.nil?
    when Hash
      DataStruct.recursive_new(value)
    when ActiveResource::Base
      DataStruct.recursive_new(value)
    when DataStruct
      value
    when Array
      value.map { |element| DataStruct.recursive_new(element) }
    end
  end
  # rubocop:enable Style/RescueModifier

  def serialize(value)
    case value
    when Hash, DataStruct
      ActiveSupport::JSON.encode(value)
    else
      super
    end
  end

  def changed_in_place?(raw_old_value, new_value)
    cast_value(raw_old_value) != new_value
  end
end
