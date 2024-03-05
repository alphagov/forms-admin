module ApiRequestHeaders
  def api_get_request_headers
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Accept" => "application/json",
    }
  end

  alias_method :api_delete_request_headers, :api_get_request_headers

  def api_post_request_headers
    {
      "X-API-Token" => Settings.forms_api.auth_key,
      "Content-Type" => "application/json",
    }
  end

  alias_method :api_patch_request_headers, :api_post_request_headers
  alias_method :api_put_request_headers, :api_post_request_headers

  alias_method :headers, :api_get_request_headers
  alias_method :delete_headers, :api_delete_request_headers
  alias_method :patch_headers, :api_patch_request_headers
  alias_method :post_headers, :api_post_request_headers
  alias_method :put_headers, :api_put_request_headers
end

RSpec.configure do |config|
  config.include ApiRequestHeaders
end
