require "resolv"

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include AfterSignInPathHelper
  before_action :set_request_id
  before_action :check_maintenance_mode_is_enabled
  before_action :authenticate_and_check_access
  before_action :set_paper_trail_whodunnit
  before_action :redirect_if_account_not_completed

  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  add_flash_types :success

  rescue_from ActiveResource::ResourceNotFound do
    render template: "errors/not_found", status: :not_found
  end

  rescue_from FormPolicy::UserMissingOrganisationError do
    render template: "errors/user_missing_organisation_error", status: :forbidden
  end

  rescue_from Pundit::NotAuthorizedError do |_exception|
    # Useful when we start adding more policies that require custom errors
    # policy_name = exception.policy.class.to_s.underscore
    # permission_error_msg = t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default

    render "errors/forbidden", status: :forbidden, formats: :html
  end

  PRIVILEGED_AUTH0_CONNECTION_STRATEGIES = %w[
    google-apps
  ].freeze

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
    payload[:page_id] = params[:page_id] if params[:page_id].present?
    payload[:session_id_hash] = Digest::SHA256.hexdigest session.id.to_s if session.exists?
    payload[:trace_id] = request.env["HTTP_X_AMZN_TRACE_ID"].presence
  end

  def set_request_id
    # Pass the request id to the API to enable tracing
    if Rails.env.production?
      [Form, Page].each do |active_resource_model|
        active_resource_model.headers["X-Request-ID"] = request.request_id
      end
    end
  end

  # Because determining the clients real IP is hard, simply return the first
  # value of the x-forwarded_for, checking it's an IP. This will probably be
  # enough for our basic monitoring
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

  def current_form
    @current_form ||= Form.find(params[:form_id])
  end

  def groups_enabled
    @groups_enabled ||= current_user.present? && FeatureService.new(current_user).enabled?(:groups)
  end

  def masquerading_enabled
  @masquerading_enabled ||= Settings.masquerading_enabled
  end

private

  def masquerade_as(user)
    warden.set_user(user, scope: :user)
    session[:masquerading_user_id] = user.id
    session[:original_user_id] = current_user.id
    @current_user = user
    @groups_enabled = FeatureService.new(@current_user).enabled?(:groups)
    redirect_to root_path
  end

  def stop_masquerading
    redirect_to root_path unless session[:masquerading_user_id].present?

    original_user = User.find_by(id: session[:original_user_id])
    redirect_to root_path unless original_user.present?

    warden.set_user(original_user)
    @current_user = original_user
    @groups_enabled = FeatureService.new(@current_user).enabled?(:groups)
    session[:masquerading_user_id] = nil
    session[:original_user_id] = nil
    redirect_to root_path
  end

  def authenticate_and_check_access
    authenticate_user!

    # check access
    unless @current_user.has_access? && auth_strategy_permitted?
      render "errors/access_denied", status: :forbidden, formats: :html
    end

    # Check if currently masquerading
    if session[:masquerading_user_id].present?
      @current_user = User.find(session[:masquerading_user_id])
      warden.set_user(@current_user)
    end
  end

  def non_maintenance_bypass_ip_address?
    bypass_ips = Settings.maintenance_mode.bypass_ips

    return true if bypass_ips.blank?

    bypass_ip_list = bypass_ips.split(",").map { |ip| IPAddr.new ip.strip }
    bypass_ip_list.none? { |ip| ip.include?(user_ip(request.env.fetch("HTTP_X_FORWARDED_FOR", ""))) }
  end

  def auth_strategy_permitted?
    return true if %w[mock_gds_sso developer].include? Settings.auth_provider

    @current_user.super_admin? ? PRIVILEGED_AUTH0_CONNECTION_STRATEGIES.include?(warden.session["auth0_connection_strategy"]) : true
  end

  def redirect_if_account_not_completed
    return if current_user.blank?

    redirect_to next_account_path if next_account_path.present?
  end
end
