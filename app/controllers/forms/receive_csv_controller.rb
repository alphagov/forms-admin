module Forms
  class ReceiveCsvController < ApplicationController
    after_action :verify_authorized

    def new
      authorize current_form, :can_view_form?
    end

    def create
      authorize current_form, :can_view_form?
    end
  end
end
