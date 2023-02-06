module CheckFormOrganisation
  def self.included(base)
    base.before_action :check_form_organisation
  end

private

  def check_form_organisation
    return nil if params[:form_id].blank?

    form = Form.find(params[:form_id])
    if form.org == @current_user.organisation_slug
      nil
    else
      render "errors/forbidden", status: :forbidden, formats: :html
    end
  end
end
