class MouSignaturesController < ApplicationController
  after_action :verify_authorized, only: %i[index]

  def index
    authorize MouSignature, :can_manage_mous?
    @mou_signatures = MouSignature.all
    render template: "mou_signatures/index", locals: { mou_signatures: @mou_signatures }
  end

  def show
    @mou_signature = current_user.current_organisation_mou_signature
    redirect_to new_mou_signature_url if @mou_signature.nil?
  end

  def new
    return redirect_to mou_signature_url if already_signed?

    @mou_signature = MouSignature.new
  end

  def create
    @mou_signature = MouSignature.new(mou_signature_params)
    @mou_signature.user = current_user
    @mou_signature.organisation = current_user.organisation

    if @mou_signature.save
      redirect_to confirmation_mou_signature_url
    else
      render(:new, status: :unprocessable_entity)
    end
  rescue ActiveRecord::RecordNotUnique
    render(:new, status: :unprocessable_entity)
  end

  def confirmation
    redirect_to new_mou_signature_url unless already_signed?
  end

private

  def mou_signature_params
    params.require(:mou_signature).permit(:agreed)
  end

  def already_signed?
    current_user.has_signed_current_organisation_mou?
  end
end
