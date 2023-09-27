class Pages::TypeOfAnswerController < PagesController
  def new
    @type_of_answer_form = Pages::TypeOfAnswerForm.new(answer_type: draft_question.answer_type)
    @type_of_answer_path = type_of_answer_create_path(@form)
    render "pages/type-of-answer"
  end

  def create
    @type_of_answer_form = Pages::TypeOfAnswerForm.new(answer_type_form_params)

    if @type_of_answer_form.submit
      redirect_to next_page_path(@form, @type_of_answer_form.answer_type, :create)
    else
      @type_of_answer_path = type_of_answer_create_path(@form)
      render "pages/type-of-answer"
    end
  end

  def edit
    @type_of_answer_form = Pages::TypeOfAnswerForm.new(answer_type: draft_question.answer_type)
    @type_of_answer_path = type_of_answer_update_path(@form)
    render "pages/type-of-answer"
  end

  def update
    @type_of_answer_form = Pages::TypeOfAnswerForm.new(answer_type_form_params)

    if @type_of_answer_form.submit
      redirect_to next_page_path(@form, @type_of_answer_form.answer_type, :update)
    else
      @type_of_answer_path = type_of_answer_update_path(@form)
      render "pages/type-of-answer"
    end
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
    params.require(:pages_type_of_answer_form).permit(:answer_type).merge(draft_question:)
  end

  def answer_type_changed?
    @type_of_answer_form.answer_type != @page.answer_type
  end

  def default_answer_settings_for_answer_type(answer_type)
    case answer_type
    when "selection"
      Pages::SelectionsSettingsForm::DEFAULT_OPTIONS
    when "text", "date", "address"
      { input_type: nil }
    when "name"
      { input_type: nil, title_needed: nil }
    else
      {}
    end
  end
end
