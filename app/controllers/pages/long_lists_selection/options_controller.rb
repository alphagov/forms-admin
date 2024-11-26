class Pages::LongListsSelection::OptionsController < PagesController
  def new
    @selection_options_input = Pages::Selection::OptionsInput.new(selection_options: draft_question.answer_settings[:selection_options]
                                                                                         .map { |option| { name: option[:name] } },
                                                                  include_none_of_the_above: draft_question.is_optional,
                                                                  draft_question:)
    @selection_options_path = long_lists_selection_options_create_path(current_form)
    @back_link_url = long_lists_selection_type_new_path(current_form)
    @bulk_options_url = long_lists_selection_bulk_options_new_path(current_form)
    render "pages/long_lists_selection/options", locals: { current_form: }
  end

  def create
    @selection_options_input = Pages::Selection::OptionsInput.new(selection_options: selection_options_param_values,
                                                                  include_none_of_the_above: include_none_of_the_above_param_values,
                                                                  draft_question:)
    @selection_options_path = long_lists_selection_options_create_path(current_form)
    @back_link_url = long_lists_selection_type_new_path(current_form)
    @bulk_options_url = long_lists_selection_bulk_options_new_path(current_form)

    if params[:add_another]
      @selection_options_input.add_another
      render "pages/long_lists_selection/options", locals: { current_form: }
    elsif params[:remove]
      @selection_options_input.remove(params[:remove].to_i)
      render "pages/long_lists_selection/options", locals: { current_form: }
    elsif @selection_options_input.submit
      redirect_to new_question_path(current_form)
    else
      render "pages/long_lists_selection/options", locals: { current_form: }
    end
  end

  def edit
    @selection_options_input = Pages::Selection::OptionsInput.new(selection_options: draft_question.answer_settings[:selection_options]
                                                                                                  .map { |option| { name: option[:name] } },
                                                                  include_none_of_the_above: draft_question.is_optional,
                                                                  draft_question:)
    @selection_options_path = long_lists_selection_options_update_path(current_form)
    @back_link_url = edit_question_path(current_form)
    @bulk_options_url = long_lists_selection_bulk_options_edit_path(current_form)
    render "pages/long_lists_selection/options", locals: { current_form: }
  end

  def update
    @selection_options_input = Pages::Selection::OptionsInput.new(selection_options: selection_options_param_values,
                                                                  include_none_of_the_above: include_none_of_the_above_param_values,
                                                                  draft_question:)
    @selection_options_path = long_lists_selection_options_update_path(current_form)
    @back_link_url = edit_question_path(current_form)
    @bulk_options_url = long_lists_selection_bulk_options_edit_path(current_form)

    if params[:add_another]
      @selection_options_input.add_another
      render "pages/long_lists_selection/options", locals: { current_form: }
    elsif params[:remove]
      @selection_options_input.remove(params[:remove].to_i)
      render "pages/long_lists_selection/options", locals: { current_form: }
    elsif @selection_options_input.submit
      redirect_to edit_question_path(current_form)
    else
      render "pages/long_lists_selection/options", locals: { current_form: }
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
