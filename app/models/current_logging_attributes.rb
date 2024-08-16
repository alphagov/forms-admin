class CurrentLoggingAttributes < ActiveSupport::CurrentAttributes
  attribute :host, :request_id, :session_id_hash, :trace_id, :user_ip,
            :user_id, :user_email, :user_organisation_slug, :acting_as_user_id,
            :acting_as_user_email, :acting_as_user_organisation_slug, :form_id,
            :page_id
end
