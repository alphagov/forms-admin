class FormListPresenter
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include GovukRailsCompatibleLinkHelper

  attr_accessor :forms, :group

  class << self
    def call(**args)
      new(**args)
    end
  end

  def initialize(forms:, group:)
    @forms = forms
    @group = group
    @list_of_creator_id = forms.map(&:creator_id).uniq
    @list_of_creators = User.where(id: @list_of_creator_id)
                             .select(:id, :name)
                             .map { |user| { id: user.id, name: user.name } }
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
    I18n.t("groups.form_table_caption", group_name: group.name)
  end

  def head
    [
      I18n.t("home.form_name_heading"),
      { text: I18n.t("home.created_by") },
      { text: I18n.t("home.form_status_heading"), numeric: true },
    ].compact
  end

  def rows
    forms.sort_by { |form| [form.name.downcase, form.created_at] }.map do |form|
      [{ text: form_name_link(form) },
       { text: find_creator_name(form) },
       { text: form_status_tags(form), numeric: true }].compact
    end
  end

  def form_name_link(form)
    govuk_link_to(form.name, FormService.new(form).path_for_state)
  end

  def form_status_tags(form)
    # Create an instance of controller. We are using ApplicationController here.
    view_context = ApplicationController.new.view_context

    status_mapping = {
      draft: -> { form.has_draft_version },
      live: -> { form.is_live? },
      archived: -> { form.is_archived? },
    }

    html_content = status_mapping.map { |status, condition|
      tag_html(status) if condition.call
    }.compact.join

    html = "<div class='app-form-states'>#{html_content}</div>"

    html.html_safe
  end

  def find_creator_name(form)
    @list_of_creators.find { |creator| creator[:id] == form.creator_id }&.fetch(:name, "")
  end

  def tag_html(status)
    status = status.to_sym
    color = status_colour(status)
    status_text = status_text(status)
    "<strong class='govuk-tag govuk-tag--#{color}'>#{status_text}</strong>"
  end

  def status_colour(status)
    {
      draft: "yellow",
      live: "turquoise",
      archived: "orange",
    }[status]
  end

  def status_text(status)
    # i18n-tasks-use t('form_statuses.draft')
    # i18n-tasks-use t('form_statuses.live')
    I18n.t("form_statuses.#{status}")
  end
end
