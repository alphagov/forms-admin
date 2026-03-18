class Pages::TypeOfAnswerController < PagesController
  def new
    @type_of_answer_input = Pages::TypeOfAnswerInput.new(answer_type: draft_question.answer_type)
    @type_of_answer_path = type_of_answer_create_path(current_form.id)
    render :type_of_answer, locals: { current_form: }
  end

  def create
    @type_of_answer_input = Pages::TypeOfAnswerInput.new(answer_type_form_params)

    if @type_of_answer_input.submit
      redirect_to next_page_path(@type_of_answer_input.answer_type)
    else
      @type_of_answer_path = type_of_answer_create_path(current_form.id)
      render :type_of_answer, locals: { current_form: }
    end
  end

  def edit
    @type_of_answer_input = Pages::TypeOfAnswerInput.new(answer_type: draft_question.answer_type)
    @type_of_answer_path = type_of_answer_update_path(current_form.id)
    render :type_of_answer, locals: { current_form: }
  end

  def update
    @type_of_answer_input = Pages::TypeOfAnswerInput.new(answer_type_form_params)

    if @type_of_answer_input.submit
      redirect_to next_page_path(@type_of_answer_input.answer_type)
    else
      @type_of_answer_path = type_of_answer_update_path(current_form.id)
      render :type_of_answer
    end
  end

private

  def answer_type_form_params
    params.require(:pages_type_of_answer_input).permit(:answer_type).merge(draft_question:, current_form:)
  end

  def answer_type_changed?
    @type_of_answer_input.answer_type != @type_of_answer_input.draft_question.answer_type
  end

  def next_page_path(answer_type)
    Pages::AddOrEditQuestionService.new(form_id: current_form.id, existing_page_id: page_id).new_or_edit_path_for_answer_type(answer_type)
  end
end
