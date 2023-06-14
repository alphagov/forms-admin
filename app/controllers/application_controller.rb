require "resolv"

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  before_action :set_request_id
  before_action :check_maintenance_mode_is_enabled
  before_action :authenticate_and_check_access
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  before_action :clear_questions_session_data

  add_flash_types :success

  rescue_from Pundit::NotAuthorizedError do |_exception|
    # Useful when we start adding more policies that require custom errors
    # policy_name = exception.policy.class.to_s.underscore
    # permission_error_msg = t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default

    render "errors/forbidden", status: :forbidden, formats: :html
  end

  def check_maintenance_mode_is_enabled
    if Settings.maintenance_mode.enabled && non_maintenance_bypass_ip_address?
      redirect_to maintenance_page_path
    end
  end

  def append_info_to_payload(payload)
    super
    payload[:host] = request.host
    if current_user.present?
      payload[:user_id] = current_user.id
      payload[:user_email] = current_user.email
      payload[:user_organisation_slug] = current_user.organisation&.slug
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

  # Because determining the clients real IP is hard, simply return the first
  # value of the x-forwarded_for, checking it's an IP. This will probably be
  # enough for out basic monitoring in PaaS
  def user_ip(forwarded_for = "")
    first_ip_string = forwarded_for.split(",").first
    Regexp.union([Resolv::IPv4::Regex, Resolv::IPv6::Regex]).match(first_ip_string) && first_ip_string
  end

  def warden
    request.env["warden"]
  end

  def user_signed_in
    warden && warden.authenticated? && !warden.user.remotely_signed_out?
  end

  def current_user
    warden.user if user_signed_in
  end

  def authenticate_user!
    warden.authenticate! Settings.auth_provider.to_sym

    # set user instance variable for views
    @current_user = current_user
  end

private

  def authenticate_and_check_access
    authenticate_user!

    # check access
    unless current_user.has_access?
      render "errors/access_denied", status: :forbidden, formats: :html
    end
  end

  def non_maintenance_bypass_ip_address?
    bypass_ips = Settings.maintenance_mode.bypass_ips

    return true if bypass_ips.blank?

    bypass_ip_list = bypass_ips.split(",").map { |ip| IPAddr.new ip.strip }
    bypass_ip_list.none? { |ip| ip.include?(user_ip(request.env.fetch("HTTP_X_FORWARDED_FOR", ""))) }
  end
end
