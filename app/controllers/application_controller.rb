require "resolv"

class ApplicationController < ActionController::Base
  include GDS::SSO::ControllerMethods
  before_action :set_request_id
  before_action :authenticate_user!
  before_action :set_user_instance_variable
  before_action :check_service_unavailable
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  before_action :clear_questions_session_data

  def check_service_unavailable
    if ENV["SERVICE_UNAVAILABLE"].present?
      render "errors/service_unavailable", status: :service_unavailable, formats: :html
    end
  end

  def set_user_instance_variable
    @current_user = current_user
  end

  def append_info_to_payload(payload)
    super
    payload[:host] = request.host
    if current_user.present?
      payload[:user_id] = current_user.id
      payload[:user_email] = current_user.email
      payload[:user_organisation_slug] = current_user.organisation_slug
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
