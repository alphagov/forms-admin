module Forms
  class ContactDetailsController < BaseController
    def new
      @contact_details_form = ContactDetailsForm.new(form: current_form).assign_form_values
    end

    def create
      @contact_details_form = ContactDetailsForm.new(**contact_details_form_params)

      if @contact_details_form.submit
        redirect_to form_path(@contact_details_form.form)
      else
        render :new
      end
    end

  private

    def contact_details_form_params
      params.require(:forms_contact_details_form).permit(:email, :phone, :link_href, :link_text, contact_details_supplied: []).merge(form: current_form)
    end
  end
end
