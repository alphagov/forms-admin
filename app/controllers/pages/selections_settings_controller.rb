class Pages::SelectionsSettingsController < PagesController
  def new
    answer_settings = load_answer_settings_from_session
    @selections_settings_form = Forms::SelectionsSettingsForm.new(answer_settings)
    @selections_settings_path = selections_settings_create_path(@form)
    @back_link_url = type_of_answer_new_path(@form)
    render selection_settings_view
  end

  def create
    answer_settings = load_answer_settings_from_params(selections_settings_form_params)
    @selections_settings_form = Forms::SelectionsSettingsForm.new(answer_settings)
    @selections_settings_path = selections_settings_create_path(@form)
    @back_link_url = type_of_answer_new_path(@form)

    if params[:add_another]
      @selections_settings_form.add_another
      render selection_settings_view
    elsif params[:remove]
      @selections_settings_form.remove(params[:remove].to_i)
      render selection_settings_view
    elsif @selections_settings_form.valid? && @selections_settings_form.submit(session)
      redirect_to new_page_path(@form)
    else
      render selection_settings_view
    end
  end

  def edit
    @page = Page.find(params[:page_id], params: { form_id: @form.id })
    @page.load_from_session(session, "answer_type")
    @page.load_from_session(session, "answer_settings")
    @page.load_from_session(session, "is_optional")

    @selections_settings_path = selections_settings_update_path(@form)
    @selections_settings_form = Forms::SelectionsSettingsForm.new(load_answer_settings_from_page_object(@page))
    @back_link_url = edit_page_path(@form, @page)
    render selection_settings_view
  end

  def update
    @page = Page.find(params[:page_id], params: { form_id: @form.id })
    @selections_settings_path = selections_settings_update_path(@form)
    answer_settings = load_answer_settings_from_params(selections_settings_form_params)
    @selections_settings_form = Forms::SelectionsSettingsForm.new(answer_settings)
    @back_link_url = edit_page_path(@form, @page)

    if params[:add_another]
      @selections_settings_form.add_another
      render selection_settings_view
    elsif params[:remove]
      @selections_settings_form.remove(params[:remove].to_i)
      render selection_settings_view
    elsif @selections_settings_form.valid? && @selections_settings_form.submit(session)

      redirect_to edit_page_path(@form)
    else
      render selection_settings_view
    end
  end

private

  def convert_to_selection_option(hash)
    Forms::SelectionOption.new(hash)
  end

  def load_answer_settings_from_params(params)
    selection_options = params[:selection_options] ? params[:selection_options].values.map(&method(:convert_to_selection_option)) : []
    only_one_option = params[:only_one_option]
    include_none_of_the_above = params[:include_none_of_the_above]

    { selection_options:, only_one_option:, include_none_of_the_above: }
  end

  def load_answer_settings_from_session
    if session[:page].present? && session[:page]["answer_settings"].present?
      only_one_option = session[:page]["answer_settings"]["only_one_option"]
      include_none_of_the_above = session[:page]["is_optional"]
      selection_options = session[:page]["answer_settings"]["selection_options"].map(&method(:convert_to_selection_option))

      { only_one_option:, selection_options:, include_none_of_the_above: }
    else
      Forms::SelectionsSettingsForm.new.default_options
    end
  end

  def load_answer_settings_from_page_object(page)
    only_one_option = page.answer_settings.only_one_option
    include_none_of_the_above = page.is_optional
    selection_options = page.answer_settings.selection_options

    { only_one_option:, selection_options:, include_none_of_the_above: }
  end

  def selections_settings_form_params
    params.require(:forms_selections_settings_form).permit(:only_one_option, :include_none_of_the_above, selection_options: [:name])
  end

  def selection_settings_view
    "pages/selections_settings"
  end
end
