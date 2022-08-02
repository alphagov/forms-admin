class Form < ActiveResource::Base
  self.site = "#{ENV['API_BASE']}/api/v1"
  self.include_format_in_path = false
  self.headers["X-API-Token"] = ENV["API_KEY"]

  has_many :pages
end
