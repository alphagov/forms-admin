class FormListService
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include GovukRailsCompatibleLinkHelper

  attr_accessor :forms, :current_user, :organisation

  class << self
    def call(**args)
      new(**args)
    end
  end

  def initialize(forms:, current_user:, organisation: nil)
    @forms = forms
    @current_user = current_user
    @organisation = organisation
    unless current_user.trial?
      @list_of_creator_id = forms.map(&:creator_id).uniq
      @list_of_creators = User.where(id: @list_of_creator_id)
                               .select(:id, :name)
                               .map { |user| { id: user.id, name: user.name } }
    end
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
    [
      I18n.t("home.form_name_heading"),
      (current_user.trial? ? nil : { text: I18n.t("home.created_by") }),
      { text: I18n.t("home.form_status_heading"), numeric: true },
    ].compact
  end

  def rows
    forms.map do |form|
      [{ text: form_name_link(form) },
       (current_user.trial? ? nil : { text: find_creator_name(form) }),
       { text: form_status_tags(form), numeric: true }].compact
    end
  end

  def organisation_name_for_caption
    return nil if current_user.trial? || current_user.organisation.blank?
    return organisation.name if current_user.super_admin?

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

    status_mapping = {
      draft: -> { form.has_draft_version },
      live: -> { form.has_live_version && !form.is_archived? },
      archived: -> { form.is_archived? },
    }

    html_content = status_mapping.map { |status, condition|
      FormStatusTagComponent::View.new(status:).render_in(view_context) if condition.call
    }.compact.join

    html = "<div class='app-form-states'>#{html_content}</div>"

    html.html_safe
  end

  def find_creator_name(form)
    @list_of_creators.find { |creator| creator[:id] == form.creator_id }&.fetch(:name, "")
  end
end
