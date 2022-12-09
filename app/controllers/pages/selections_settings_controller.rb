class Pages::SelectionsSettingsController < PagesController
  def new
    answer_settings = load_answer_settings_from_session
    @selections_settings_form = Forms::SelectionsSettingsForm.new(answer_settings)
    @selections_settings_path = selections_settings_create_path(@form)
    @back_link_url = type_of_answer_new_path(@form)
    render selection_settings_view
  end

  def create
    @selections_settings_form = Forms::SelectionsSettingsForm.new(selections_settings_form_params)
    @selections_settings_path = selections_settings_create_path(@form)
    @back_link_url = type_of_answer_new_path(@form)

    if params[:add_another]
      @selections_settings_form.add_another
      render selection_settings_view
    elsif params[:remove]
      @selections_settings_form.remove(params[:remove].to_i)
      render selection_settings_view
    elsif @selections_settings_form.submit(session)
      redirect_to new_page_path(@form)
    else
      render selection_settings_view
    end
  end

  def edit
    @page = Page.find(params[:page_id], params: { form_id: @form.id })
    @selections_settings_path = selections_settings_update_path(@form)
    @selections_settings_form = Forms::SelectionsSettingsForm.new(load_form_from_params(@page.answer_settings))
    @back_link_url = edit_page_path(@form, @page)
    render selection_settings_view
  end

  def update
    @page = Page.find(params[:page_id], params: { form_id: @form.id })
    @selections_settings_path = selections_settings_update_path(@form)
    @selections_settings_form = Forms::SelectionsSettingsForm.new(selections_settings_form_params)
    @back_link_url = edit_page_path(@form, @page)

    if params[:add_another]
      @selections_settings_form.add_another
      render selection_settings_view
    elsif params[:remove]
      @selections_settings_form.remove(params[:remove].to_i)
      render selection_settings_view
    else
      @selections_settings_form.assign_values_to_page(@page)

      if @page.save!
        redirect_to edit_page_path(@form)
      else
        render selection_settings_view
      end
    end
  end

private

  def convert_array_to_indexed_object(array)
    Hash[(0...JSON.parse(array.to_json).size).zip JSON.parse(array.to_json)]
  end

  def load_answer_settings_from_session
    if session[:page].present? && session[:page]["answer_settings"].present?
      only_one_option = session[:page]["answer_settings"]["only_one_option"]
      include_none_of_the_above = session[:page]["is_optional"]
      selection_options = convert_array_to_indexed_object(session[:page]["answer_settings"]["selection_options"])

      { only_one_option:, selection_options:, include_none_of_the_above: }
    else
      { selection_options: { "0" => { "name": "" }, "1" => { "name": "" } }, only_one_option: false, include_none_of_the_above: false }
    end
  end

  def load_form_from_params(answer_settings)
    if answer_settings.nil?
      { only_one_option: false, selection_options: { "0" => { name: "" }, "1" => { name: "" } } }
    else
      only_one_option = answer_settings.only_one_option
      selection_options = convert_array_to_indexed_object(answer_settings.selection_options)

      { only_one_option:, selection_options:, include_none_of_the_above: @page.is_optional }
    end
  end

  def selections_settings_form_params
    params.require(:forms_selections_settings_form).permit(:only_one_option, :include_none_of_the_above, selection_options: [:name])
  end

  def selection_settings_view
    "pages/selections_settings"
  end
end
