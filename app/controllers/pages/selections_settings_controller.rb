class Pages::SelectionsSettingsController < PagesController
  def new
    answer_settings = load_answer_settings_from_session
    @selections_settings_form = Pages::SelectionsSettingsForm.new(answer_settings)
    @selections_settings_path = selections_settings_create_path(current_form)
    @back_link_url = question_text_new_path(current_form)
    render :selections_settings, locals: { current_form: }
  end

  def create
    answer_settings = load_answer_settings_from_params(selections_settings_form_params)
    # TODO: Can remove the merge once we replaced session storage with ActiveRecord
    @selections_settings_form = Pages::SelectionsSettingsForm.new(answer_settings.merge(draft_question:))
    @selections_settings_path = selections_settings_create_path(current_form)
    @back_link_url = question_text_new_path(current_form)

    if params[:add_another]
      @selections_settings_form.add_another
      render :selections_settings, locals: { current_form: }
    elsif params[:remove]
      @selections_settings_form.remove(params[:remove].to_i)
      render :selections_settings, locals: { current_form: }
    elsif @selections_settings_form.submit(session)
      redirect_to new_question_path(current_form)
    else
      render :selections_settings, locals: { current_form: }
    end
  end

  def edit
    page.load_from_session(session, %i[answer_type answer_settings is_optional])
    @selections_settings_path = selections_settings_update_path(current_form)
    @selections_settings_form = Pages::SelectionsSettingsForm.new(load_answer_settings_from_page_object(page))
    @back_link_url = edit_question_path(current_form, page)
    render :selections_settings, locals: { current_form: }
  end

  def update
    answer_settings = load_answer_settings_from_params(selections_settings_form_params)
    # TODO: Can remove the merge once we replaced session storage with ActiveRecord
    @selections_settings_form = Pages::SelectionsSettingsForm.new(answer_settings.merge(draft_question:))
    @selections_settings_path = selections_settings_update_path(current_form)
    @back_link_url = edit_question_path(current_form, page)

    if params[:add_another]
      @selections_settings_form.add_another
      render :selections_settings, locals: { current_form: }
    elsif params[:remove]
      @selections_settings_form.remove(params[:remove].to_i)
      render :selections_settings, locals: { current_form: }
    elsif @selections_settings_form.submit(session)
      redirect_to edit_question_path(current_form)
    else
      render :selections_settings, locals: { current_form: }
    end
  end

private

  def load_answer_settings_from_params(params)
    selection_options = params[:selection_options] ? params[:selection_options].values : []
    only_one_option = params[:only_one_option]
    include_none_of_the_above = params[:include_none_of_the_above]

    { selection_options:, only_one_option:, include_none_of_the_above: }
  end

  def load_answer_settings_from_session
    if session[:page].present? && session[:page][:answer_settings].present?
      only_one_option = session[:page][:answer_settings][:only_one_option]
      include_none_of_the_above = session[:page][:is_optional]
      selection_options = session[:page][:answer_settings][:selection_options]

      { only_one_option:, selection_options:, include_none_of_the_above: }
    else
      Pages::SelectionsSettingsForm::DEFAULT_OPTIONS
    end
  end

  def load_answer_settings_from_page_object(page)
    only_one_option = page.answer_settings.only_one_option
    include_none_of_the_above = page.is_optional
    selection_options = page.answer_settings.selection_options.map { |option| { name: option.name } }

    { only_one_option:, selection_options:, include_none_of_the_above: }
  end

  def selections_settings_form_params
    params.require(:pages_selections_settings_form)
          .permit(:only_one_option, :include_none_of_the_above, selection_options: [:name]).to_h.deep_symbolize_keys
  end
end
