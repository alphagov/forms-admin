# frozen_string_literal: true

module FormsHelper
  def forms_table_caption(organisation_name)
    return t("home.your_forms") if organisation_name.blank?

    t("home.form_table_caption", organisation_name:)
  end

  def user_organisation_name(user)
    return nil if user.trial? || user.organisation.blank?

    user.organisation.name
  end
end
