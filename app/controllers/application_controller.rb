require "resolv"

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  before_action :set_request_id
  before_action :check_maintenance_mode_is_enabled
  before_action :authenticate_and_check_access
  before_action :set_paper_trail_whodunnit
  before_action :check_user_account_complete

  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  before_action :clear_draft_questions_data

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

  def clear_draft_questions_data
    current_user.draft_questions.destroy_all if current_user.present?
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

private

  def authenticate_and_check_access
    authenticate_user!

    # check access
    unless @current_user.has_access? && auth_strategy_permitted?
      render "errors/access_denied", status: :forbidden, formats: :html
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

  def check_user_account_complete
    return unless current_user

    return redirect_to edit_account_organisation_path if current_user.organisation.blank?

    redirect_to edit_account_name_path if current_user.name.blank?
  end
end
