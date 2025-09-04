class Forms::GroupSelectPresenter
  class << self
    def call(**args)
      new(**args)
    end
  end

  def initialize(form:, group:, groups:)
    @form = form
    @group = group
    @groups = groups
  end

  def group_name(group)
    return group.name if @form.has_live_version || @form.has_been_archived

    "#{group.name} (#{group.status.humanize})"
  end

  def legend
    return I18n.t("helpers.legend.forms_group_select.no_active_groups") if (@form.is_live? || @form.is_archived?) && @groups.empty?
    return I18n.t("helpers.legend.forms_group_select.no_groups") if @groups.empty?

    I18n.t("helpers.legend.forms_group_select.group")
  end

  def hint
    return I18n.t("helpers.hint.forms_group_select.no_active_groups") if @form.is_live? && @groups.empty?
    return I18n.t("helpers.hint.forms_group_select.no_groups") if @groups.empty?
    return I18n.t("helpers.hint.forms_group_select.group") if (@form.is_live? || @form.is_archived?) && @groups.present?

    ""
  end
end
