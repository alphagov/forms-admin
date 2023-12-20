class MakeFormLiveService
  class << self
    def call(**args)
      new(**args)
    end
  end

  def initialize(draft_form:)
    @draft_form = draft_form
  end

  def make_live
    @draft_form.make_live!
  end

  def page_title
    if @draft_form.has_live_version
      I18n.t("page_titles.your_changes_are_live")
    else
      I18n.t("page_titles.your_form_is_live")
    end
  end
end
