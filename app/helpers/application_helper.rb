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

  def link_to_runner(runner_url, form_id, form_slug, live: false)
    mode_segment = live ? "form" : "preview-form"
    "#{runner_url}/#{mode_segment}/#{form_id}/#{form_slug}"
  end
end
