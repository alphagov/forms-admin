class Form < ActiveResource::Base
  self.site = "#{ENV['API_BASE']}/v1"
  self.include_format_in_path = false
end
