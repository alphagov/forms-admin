require "resolv"

class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods unless Settings.basic_auth.enabled
  include Pundit::Authorization
  before_action :set_request_id
  before_action :authenticate
  before_action :check_service_unavailable
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  before_action :clear_questions_session_data

  rescue_from Pundit::NotAuthorizedError do |_exception|
    # Useful when we start adding more policies that require custom errors
    # policy_name = exception.policy.class.to_s.underscore
    # permission_error_msg = t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default

    render "errors/forbidden", status: :forbidden, formats: :html
  end

  def authenticate
    if Settings.basic_auth.enabled
      basic_auth
    else
      signon_auth
    end
  end

  def basic_auth
    request.env["warden"].manager.config.intercept_401 = false

    http_basic_authenticate_or_request_with(
      name: Settings.basic_auth.username,
      password: Settings.basic_auth.password,
    )

    @current_user = User.new(
      name: Settings.basic_auth.username,
      email: "#{Settings.basic_auth.username}@example.com",
      organisation_slug: "government-digital-service",
    )
  end

  def signon_auth
    authenticate_user!
    @current_user = current_user
  end

  def check_service_unavailable
    if Settings.service_unavailable
      render "errors/service_unavailable", status: :service_unavailable, formats: :html
    end
  end

  def append_info_to_payload(payload)
    super
    payload[:host] = request.host
    if @current_user.present?
      payload[:user_id] = @current_user.id
      payload[:user_email] = @current_user.email
      payload[:user_organisation_slug] = @current_user.organisation_slug
    end
    payload[:request_id] = request.request_id
    payload[:user_ip] = user_ip(request.env.fetch("HTTP_X_FORWARDED_FOR", ""))
    payload[:form_id] = params[:form_id] if params[:form_id].present?
  end

  def clear_questions_session_data
    session.delete(:page) if session[:page].present?
  end

  def set_request_id
    request.request_id = request_id

    # Pass the request id to the API to enable tracing
    if Rails.env.production?
      [Form, Page].each do |active_resource_model|
        active_resource_model.headers["X-Request-ID"] = request.request_id
      end
    end
  end

  # PaaS uses a different header to pass on the request_id
  # https://github.com/cloudfoundry/gorouter/issues/148 If PaaS header exists,
  # use it, otherwise use standard header or generate new value
  def request_id
    vcap_request_id = request.env.fetch("HTTP_X_VCAP_REQUEST_ID", false)
    if vcap_request_id
      # This is a user input so take basic precautions by limiting chars to
      # range and length
      vcap_request_id.gsub(/[^\w\-@]/, "").first(255)
    else
      request.request_id
    end
  end

  # Becuase determining the clients real IP is hard, simply return the first
  # value of the x-forwarded_for, checking it's an IP. This will probably be
  # enough for out basic monitoring in PaaS
  def user_ip(forwarded_for = "")
    first_ip_string = forwarded_for.split(",").first
    Regexp.union([Resolv::IPv4::Regex, Resolv::IPv6::Regex]).match(first_ip_string) && first_ip_string
  end
end
