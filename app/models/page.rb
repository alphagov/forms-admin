class Page < ActiveResource::Base
  self.site = (ENV["API_BASE"]).to_s
  self.prefix = "/api/v1/forms/:form_id/"
  self.include_format_in_path = false

  belongs_to :form
end
