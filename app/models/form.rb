class Form < ActiveResource::Base
  self.site = "#{ENV['API_BASE']}/api/v1"
  self.include_format_in_path = false

  has_many :pages
end
