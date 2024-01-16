class FormListService
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
    }
  end

private

  def caption
    text = if organisation_name_for_caption.blank?
             I18n.t("home.your_forms")
           else
             I18n.t("home.form_table_caption", organisation_name: organisation_name_for_caption)
           end

    { text: }
  end

  def organisation_name_for_caption
    return nil if current_user.trial? || current_user.organisation.blank?
    return search_form.organisation.name if current_user.super_admin?

    current_user.organisation.name
  end
end
