class Pages::Selection::OptionsController < PagesController
  def new
    @selection_options_input = Pages::Selection::OptionsInput.new(draft_question:)
    @selection_options_input.assign_form_values
    @selection_options_path = selection_options_create_path(current_form.id)
    @back_link_url = selection_type_new_path(current_form.id)
    @bulk_options_url = selection_bulk_options_new_path(current_form.id)
    render "pages/selection/options", locals: { current_form: }
  end

  def create
    @selection_options_input = Pages::Selection::OptionsInput.new(selection_options: selection_options_param_values,
                                                                  include_none_of_the_above: include_none_of_the_above_param_values,
                                                                  draft_question:)
    @selection_options_path = selection_options_create_path(current_form.id)
    @back_link_url = selection_type_new_path(current_form.id)
    @bulk_options_url = selection_bulk_options_new_path(current_form.id)

    if params[:add_another]
      @selection_options_input.add_another
      render "pages/selection/options", locals: { current_form: }
    elsif params[:remove]
      @selection_options_input.remove(params[:remove].to_i)
      render "pages/selection/options", locals: { current_form: }
    elsif @selection_options_input.submit
      if @selection_options_input.include_none_of_the_above_with_question?
        redirect_to selection_none_of_the_above_new_path(current_form.id)
      else
        redirect_to new_question_path(current_form.id)
      end
    else
      render "pages/selection/options", locals: { current_form: }
    end
  end

  def edit
    @selection_options_input = Pages::Selection::OptionsInput.new(draft_question:)
    @selection_options_input.assign_form_values
    @selection_options_path = selection_options_update_path(current_form.id)
    @back_link_url = edit_question_path(current_form.id)
    @bulk_options_url = selection_bulk_options_edit_path(current_form.id)
    render "pages/selection/options", locals: { current_form: }
  end

  def update
    @selection_options_input = Pages::Selection::OptionsInput.new(selection_options: selection_options_param_values,
                                                                  include_none_of_the_above: include_none_of_the_above_param_values,
                                                                  draft_question:)
    @selection_options_path = selection_options_update_path(current_form.id)
    @back_link_url = edit_question_path(current_form.id)
    @bulk_options_url = selection_bulk_options_edit_path(current_form.id)

    if params[:add_another]
      @selection_options_input.add_another
      render "pages/selection/options", locals: { current_form: }
    elsif params[:remove]
      @selection_options_input.remove(params[:remove].to_i)
      render "pages/selection/options", locals: { current_form: }
    elsif @selection_options_input.submit
      if @selection_options_input.include_none_of_the_above_with_question?
        redirect_to selection_none_of_the_above_edit_path(current_form.id)
      else
        redirect_to edit_question_path(current_form.id)
      end
    else
      render "pages/selection/options", locals: { current_form: }
    end
  end

private

  def selection_options_param_values
    input_params[:selection_options] ? input_params[:selection_options].values : []
  end

  def include_none_of_the_above_param_values
    input_params[:include_none_of_the_above]
  end

  def input_params
    params.require(:pages_selection_options_input)
          .permit(:include_none_of_the_above, selection_options: [:name]).to_h.deep_symbolize_keys
  end
end
