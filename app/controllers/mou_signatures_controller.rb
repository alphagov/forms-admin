class MouSignaturesController < ApplicationController
  after_action :verify_authorized

  def index
    authorize MouSignature, :can_manage_mous?
    @mou_signatures = MouSignature.all
    render template: "mou_signatures/index", locals: { mou_signatures: @mou_signatures }
  end
end
