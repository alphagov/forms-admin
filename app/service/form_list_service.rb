# require "helpers/govuk_rails_compatible_link_helper"
class FormListService
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include GovukRailsCompatibleLinkHelper

  attr_accessor :forms, :current_user, :search_form

  class << self
    def call(**args)
      new(**args)
    end
  end

  def initialize(forms:, current_user:, search_form: nil)
    @forms = forms
    @current_user = current_user
    @search_form = search_form
  end

  def data
    {
      caption:,
      head:,
      rows:,
    }
  end

private

  def caption
    return I18n.t("home.your_forms") if organisation_name_for_caption.blank?

    I18n.t("home.form_table_caption", organisation_name: organisation_name_for_caption)
  end

  def head
    [I18n.t("home.form_name_heading"),
     { text: I18n.t("home.form_status_heading"), numeric: true }]
  end

  def rows
    forms.map do |form|
      [{ text: form_name_link(form) }, { text: form_status_tags(form), numeric: true }]
    end
  end

  def organisation_name_for_caption
    return nil if current_user.trial? || current_user.organisation.blank?
    return search_form.organisation.name if current_user.super_admin?

    current_user.organisation.name
  end

  def form_name_link(form)
    if form.has_live_version
      govuk_link_to(form.name, live_form_path(form.id))
    else
      govuk_link_to(form.name, form_path(form.id))
    end
  end

  def form_status_tags(form)
    # Create an instance of controller. We are using ApplicationController here.
    view_context = ApplicationController.new.view_context

    html = ""
    html << FormStatusTagComponent::View.new(status: :draft).render_in(view_context) if form.has_draft_version
    html << FormStatusTagComponent::View.new(status: :live).render_in(view_context) if form.has_live_version
    html.html_safe
  end
end
