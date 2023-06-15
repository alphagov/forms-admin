class Pages::TypeOfAnswerController < PagesController
  def new
    answer_type = session.dig(:page, "answer_type")
    @type_of_answer_form = Forms::TypeOfAnswerForm.new(answer_type:)
    @type_of_answer_path = type_of_answer_create_path(@form)
    render "pages/type-of-answer"
  end

  def create
    @type_of_answer_form = Forms::TypeOfAnswerForm.new(answer_type_form_params)

    if @type_of_answer_form.submit(session)
      redirect_to next_page_path(@form, @type_of_answer_form.answer_type, :create)
    else
      @type_of_answer_path = type_of_answer_create_path(@form)
      render "pages/type-of-answer"
    end
  end

  def edit
    @page = Page.find(params[:page_id], params: { form_id: @form.id })
    @page.load_from_session(session, %w[answer_type])

    @type_of_answer_form = Forms::TypeOfAnswerForm.new(answer_type: @page.answer_type, page: @page)
    @type_of_answer_path = type_of_answer_update_path(@form)
    render "pages/type-of-answer"
  end

  def update
    @page = Page.find(params[:page_id], params: { form_id: @form.id })
    answer_type = session.dig(:page, "answer_type")

    @page.load(answer_type:)
    @type_of_answer_form = Forms::TypeOfAnswerForm.new(answer_type_form_params)
    return redirect_to edit_page_path(@form) unless answer_type_changed?

    save_to_session(session)
  end

private

  def selection_path(form, action)
    action == :create ? question_text_new_path(form) : selections_settings_edit_path(form)
  end

  def text_path(form, action)
    action == :create ? text_settings_new_path(form) : text_settings_edit_path(form)
  end

  def date_path(form, action)
    action == :create ? date_settings_new_path(form) : date_settings_edit_path(form)
  end

  def address_path(form, action)
    action == :create ? address_settings_new_path(form) : address_settings_edit_path(form)
  end

  def name_path(form, action)
    action == :create ? name_settings_new_path(form) : name_settings_edit_path(form)
  end

  def default_path(form, action)
    action == :create ? new_page_path(form) : edit_page_path(form)
  end

  def next_page_path(form, answer_type, action)
    case answer_type
    when "selection"
      selection_path(form, action)
    when "text"
      text_path(form, action)
    when "date"
      date_path(form, action)
    when "address"
      address_path(form, action)
    when "name"
      name_path(form, action)
    else
      default_path(form, action)
    end
  end

  def answer_type_form_params
    form = Form.find(params[:form_id])
    params.require(:forms_type_of_answer_form).permit(:answer_type).merge(form:)
  end

  def answer_type_changed?
    @type_of_answer_form.answer_type != @page.answer_type
  end

  def default_answer_settings_for_answer_type(answer_type)
    case answer_type
    when "selection"
      Forms::SelectionsSettingsForm::DEFAULT_OPTIONS
    when "text", "date", "address"
      { input_type: nil }
    when "name"
      { input_type: nil, title_needed: nil }
    else
      {}
    end
  end

  def save_to_session(session)
    if @type_of_answer_form.submit(session)
      session[:page]["answer_settings"] = default_answer_settings_for_answer_type(@type_of_answer_form.answer_type)
      redirect_to next_page_path(@form, @type_of_answer_form.answer_type, :update)
    else
      @type_of_answer_path = type_of_answer_update_path(@form)
      render "pages/type-of-answer"
    end
  end
end
