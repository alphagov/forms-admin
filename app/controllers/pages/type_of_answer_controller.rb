class Pages::TypeOfAnswerController < PagesController
  before_action :set_answer_types

  def new
    @type_of_answer_input = Pages::TypeOfAnswerInput.new(answer_type: draft_question.answer_type, answer_types:)
    @type_of_answer_path = type_of_answer_create_path(current_form.id)
    render :type_of_answer, locals: { current_form: }
  end

  def create
    @type_of_answer_input = Pages::TypeOfAnswerInput.new(answer_type_form_params)

    if @type_of_answer_input.submit
      redirect_to next_page_path(current_form.id, @type_of_answer_input.answer_type, :create)
    else
      @type_of_answer_path = type_of_answer_create_path(current_form.id)
      render :type_of_answer, locals: { current_form: }
    end
  end

  def edit
    @type_of_answer_input = Pages::TypeOfAnswerInput.new(answer_type: draft_question.answer_type, answer_types:)
    @type_of_answer_path = type_of_answer_update_path(current_form.id)
    render :type_of_answer, locals: { current_form: }
  end

  def update
    @type_of_answer_input = Pages::TypeOfAnswerInput.new(answer_type_form_params)

    if @type_of_answer_input.submit
      redirect_to next_page_path(current_form.id, @type_of_answer_input.answer_type, :update)
    else
      @type_of_answer_path = type_of_answer_update_path(current_form.id)
      render :type_of_answer
    end
  end

private

  def selection_path(form_id, action)
    return question_text_new_path(form_id) if action == :create

    selection_type_edit_path(form_id, page.id)
  end

  def text_path(form_id, action)
    action == :create ? text_settings_new_path(form_id) : text_settings_edit_path(form_id)
  end

  def date_path(form_id, action)
    action == :create ? date_settings_new_path(form_id) : date_settings_edit_path(form_id)
  end

  def address_path(form_id, action)
    action == :create ? address_settings_new_path(form_id) : address_settings_edit_path(form_id)
  end

  def name_path(form_id, action)
    action == :create ? name_settings_new_path(form_id) : name_settings_edit_path(form_id)
  end

  def default_path(form_id, action)
    action == :create ? new_question_path(form_id) : edit_question_path(form_id)
  end

  def next_page_path(form_id, answer_type, action)
    case answer_type
    when "selection"
      selection_path(form_id, action)
    when "text"
      text_path(form_id, action)
    when "date"
      date_path(form_id, action)
    when "address"
      address_path(form_id, action)
    when "name"
      name_path(form_id, action)
    else
      default_path(form_id, action)
    end
  end

  def answer_type_form_params
    params.require(:pages_type_of_answer_input).permit(:answer_type).merge(draft_question:, answer_types:, current_form:)
  end

  def answer_type_changed?
    @type_of_answer_input.answer_type != @type_of_answer_input.draft_question.answer_type
  end

  def set_answer_types
    @answer_types = answer_types
  end

  def answer_types
    Page::ANSWER_TYPES
  end
end
