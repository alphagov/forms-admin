# frozen_string_literal: true

module ApplicationHelper
  def page_title
    [ content_for(:title), "GOV.UK Forms" ].compact.join(I18n.t("page_titles.separator"))
  end

  def set_page_title(title)
    content_for(:title, title.html_safe)
  end

  def title_with_error_prefix(title, error)
    "#{t('page_titles.error_prefix') if error}#{title}"
  end

  def govuk_back_link_to(url = :back, body = "Back")
    classes = "govuk-!-display-none-print"

    url = back_link_url if url == :back

    render GovukComponent::BackLinkComponent.new(
      text: body,
      href: url,
      classes:,
    )
  end

  def link_to_runner(runner_url, form_id, form_slug, mode: :preview_draft)
    modes = { preview_draft: "preview-draft", live: "form", preview_live: "preview-live", preview_archived: "preview-archived" }
    mode_segment = modes.fetch(mode, "preview-draft")
    "#{runner_url}/#{mode_segment}/#{form_id}/#{form_slug}"
  end

  def contact_url
    t("contact_url")
  end

  def contact_link(text = t("contact_govuk_forms"))
    govuk_link_to(text, contact_url)
  end

  def question_text_with_optional_suffix(page)
    page.show_optional_suffix? ? t("pages.optional", question_text: page.question_text) : page.question_text
  end

  def translation_key_for_answer_type(answer_type, answer_settings)
    case answer_type
    when "selection"
      answer_settings[:only_one_option] == "true" ? "radio" : "checkbox"
    when "text", "date"
      answer_settings[:input_type]
    else
      answer_type
    end
  end

  def hint_for_edit_page_field(field, answer_type, answer_settings)
    key = translation_key_for_answer_type(answer_type, answer_settings)
    t("helpers.hint.page.#{field}.#{key}", default: t("helpers.hint.page.#{field}.default"))
  end

  def question_text_label(answer_type, answer_settings)
    key = translation_key_for_answer_type(answer_type, answer_settings)
    translation_path = "helpers.label.pages_question_input.question_text"
    t("#{translation_path}.#{key}", default: t("#{translation_path}.default"))
  end

  def govuk_assets_path
    "/node_modules/govuk-frontend/dist/govuk/assets"
  end

  def header_component_options(user:)
    { navigation_items: NavigationItemsService.call(user:).navigation_items }
  end

  def user_role_options(roles = User.roles.keys)
    roles.map do |role|
      OpenStruct.new(label: t("users.roles.#{role}.name"), value: role, description: t("users.roles.#{role}.description"))
    end
  end

  def user_access_options(access_options = %w[true false])
    access_options.map do |access|
      OpenStruct.new(label: t("users.has_access.#{access}.name"), value: access, description: t("users.has_access.#{access}.description"))
    end
  end

  def sign_in_button(is_e2e_user:)
    govuk_button_to t("sign_in_button"), omniauth_authorize_path, params: sign_in_params(is_e2e_user:), data: { module: "sign-in-button" }
  end

  def sign_up_button(is_e2e_user:)
    govuk_button_to t("sign_up_button"), omniauth_authorize_path, params: sign_in_params(is_e2e_user:, login_type: :sign_up), data: { module: "sign-in-button" }
  end

  def omniauth_authorize_path
    "/auth/#{Settings.auth_provider.dasherize}"
  end

  def sign_in_params(is_e2e_user:, login_type: :sign_in)
    {}.tap do |params|
      if Settings.auth_provider == "auth0"
        params.merge!({ auth: "e2e" }) if is_e2e_user
        params.merge!({ screen_hint: "signup" }) if login_type == :sign_up
      end
    end
  end

  def init_autocomplete_script(show_all_values: false, raw_attribute: false, source: false)
    content_for(:body_end) do
      javascript_tag defer: true do
        "
      document.addEventListener('DOMContentLoaded', function(event) {
        if(window.dfeAutocomplete !== undefined && typeof window.dfeAutocomplete === 'function') {
          dfeAutocomplete({
            showAllValues: #{show_all_values},
            rawAttribute: #{raw_attribute},
            source: #{source}
          })
        }
      });
        ".html_safe
      end
    end
  end

  def acting_as?
    session[:acting_as_user_id].present?
  end

  def actual_user
    return nil unless acting_as?

    User.find(session[:original_user_id])
  end

  def acting_as_user
    return nil unless acting_as?

    request.env["warden"].user
  end

  def date_last_signed_in_at(user)
    last_signed_in_at = user.last_signed_in_at

    if last_signed_in_at.present?
      last_signed_in_at.to_date.to_fs
    elsif user.provider.to_sym == :gds
      I18n.t("last_signed_in_at.not_since_auth0_enabled")
    else
      I18n.t("last_signed_in_at.not_since_last_signed_in_at_added")
    end
  end
end
