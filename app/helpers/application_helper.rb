# frozen_string_literal: true

# Rubocop ate my lunch
module ApplicationHelper
  def page_title(separator = " – ")
    [content_for(:title), "GOV.UK Forms"].compact.join(separator)
  end

  def set_page_title(title)
    content_for(:title) { title.html_safe }
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
    modes = { preview_draft: "preview-draft", live: "form", preview_live: "preview-live" }
    mode_segment = modes.fetch(mode, "preview-draft")
    "#{runner_url}/#{mode_segment}/#{form_id}/#{form_slug}"
  end

  def contact_url
    "mailto:govuk-forms-support@govuk.zendesk.com"
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
      answer_settings.only_one_option == "true" ? "radio" : "checkbox"
    when "text", "date"
      answer_settings.input_type
    else
      answer_type
    end
  end

  def hint_for_edit_page_field(field, answer_type, answer_settings)
    key = translation_key_for_answer_type(answer_type, answer_settings)
    t("helpers.hint.page.#{field}.#{key}", default: t("helpers.hint.page.#{field}.default"))
  end

  def govuk_assets_path
    "/node_modules/govuk-frontend/govuk/assets"
  end

  def header_component_options(user:, can_manage_users:, can_manage_mous: false)
    auth_links = {
      auth0: {
        user_profile_link: nil,
        signout_link: sign_out_path,
      },
      cddo_sso: {
        user_profile_link: "https://sso.service.security.gov.uk/profile",
        signout_link: sign_out_path,
      },
      gds: {
        user_profile_link: GDS::SSO::Config.oauth_root_url,
        signout_link: gds_sign_out_path,
      },
      mock_gds_sso: {
        user_profile_link: nil,
        signout_link: sign_out_path,
      },
    }
    auth_links.default = {}
    links = auth_links[user&.provider&.to_sym]

    { is_signed_in: user.present?,
      user_name: user&.name.presence,
      user_profile_link: (user.blank? ? nil : links[:user_profile_link]),
      list_of_users_path: (can_manage_users ? users_path : nil),
      mou_path: (can_manage_mous ? mou_signatures_path : nil),
      signout_link: (user.blank? ? nil : links[:signout_link]) }
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
end
