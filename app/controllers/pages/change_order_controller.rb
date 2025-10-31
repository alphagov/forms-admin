class Pages::ChangeOrderController < PagesController
  def new
    @change_order_input = Pages::ChangeOrderInput.new(form: current_form)
    render :change_order, locals: { show_banner: false }
  end

  def create
    @change_order_input = Pages::ChangeOrderInput.new(pages_change_order_input_params)

    if is_preview?
      if @change_order_input.valid?(:preview)
        @change_order_input.update_preview
        return render :change_order, locals: { show_banner: true }
      end
    elsif @change_order_input.submit
      if @change_order_input.confirmed?
        return redirect_to form_pages_path, success: t("pages.change_order.success")
      else
        return redirect_to form_pages_path
      end
    end

    render :change_order, locals: { show_banner: false }
  rescue Pages::ChangeOrderService::FormPagesAddedError
    render "errors/change_order_pages_added", status: :unprocessable_content, formats: :html
  end

  def pages_change_order_input_params
    page_param_keys = params.require(:pages_change_order_input)
                            .keys
                            .select { |key, _value| key.starts_with?(Pages::ChangeOrderInput::INPUT_PREFIX) }

    page_position_params = params.require(:pages_change_order_input)
          .permit(*page_param_keys).to_h

    params.require(:pages_change_order_input).permit(:confirm).merge(form: current_form, page_position_params:)
  end

  def is_preview?
    params.permit(:preview)[:preview] == "true"
  end
end
