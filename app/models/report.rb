class Report < ActiveResource::Base
  self.site = Settings.forms_api.base_url
  self.prefix = "/api/v1/"
  self.include_format_in_path = false
  headers["X-API-Token"] = Settings.forms_api.auth_key

  class Form < ActiveResource::Base
    self.site = Report.site
    self.prefix = Report.prefix
  end
end
