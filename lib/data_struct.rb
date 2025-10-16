# When an OpenStruct is converted to json, it inludes @table.
# We inherit and overide as_json here to use to contain answer_settings, which
# is a json hash converted into an object by ActiveResource. Using a plain hash
# for answer_settings means there is no .access to attributes.
class DataStruct < OpenStruct
  def self.recursive_new(object)
    object.each_with_object(DataStruct.new) do |(key, value), struct|
      struct[key] = case value
                    when Hash
                      recursive_new(value)
                    when Array
                      value.map { recursive_new(it) }
                    else
                      value
                    end
    end
  end

  def as_json(*args)
    super.as_json["table"]
  end
end
