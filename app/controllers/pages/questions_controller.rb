class Pages::QuestionsController < PagesController
  before_action do
    raise "No answer type set for draft question" if draft_question.answer_type.blank?
  end

  def new
    @question_input = Pages::QuestionInput.new(answer_type: draft_question.answer_type,
                                               question_text: draft_question.question_text,
                                               answer_settings: draft_question.answer_settings,
                                               is_optional: draft_question.is_optional,
                                               is_repeatable: draft_question.is_repeatable,
                                               draft_question:)

    render :new, locals: { current_form:, draft_question: }
  end

  def create
    @question_input = Pages::QuestionInput.new(page_params_for_form_object)

    if @question_input.valid?
      @page = @question_input.submit
      clear_draft_questions_data
      redirect_to edit_question_path(current_form.id, @page.id), success: "Your changes have been saved"
    else
      render :new, locals: { current_form:, draft_question: }, status: :unprocessable_content
    end
  end

  def edit
    @question_input = Pages::QuestionInput.new(answer_type: draft_question.answer_type,
                                               question_text: draft_question.question_text,
                                               hint_text: draft_question.hint_text,
                                               is_optional: draft_question.is_optional,
                                               is_repeatable: draft_question.is_repeatable,
                                               answer_settings: draft_question.answer_settings)
    render :edit, locals: { current_form:, draft_question: }
  end

  def update
    page.assign_attributes(page_params_for_update)

    @question_input = Pages::QuestionInput.new(page_params_for_form_object)

    if @question_input.update_page(@page)
      clear_draft_questions_data
      redirect_to edit_question_path(current_form.id, @page.id), success: "Your changes have been saved"
    else
      render :edit, locals: { current_form:, draft_question: }, status: :unprocessable_content
    end
  end

private

  def page_params
    params.require(:pages_question_input).permit(:question_text, :hint_text, :is_optional, :is_repeatable)
  end

  def page_params_for_form_object
    page_params.merge(draft_question:,
                      form_id: current_form.id,
                      answer_type: draft_question.answer_type,
                      answer_settings: draft_question.answer_settings,
                      page_heading: draft_question.page_heading,
                      guidance_markdown: draft_question.guidance_markdown)
  end

  def page_params_for_update
    page_params.merge(form_id: current_form.id,
                      answer_settings: draft_question.answer_settings,
                      page_heading: draft_question.page_heading,
                      guidance_markdown: draft_question.guidance_markdown,
                      answer_type: draft_question.answer_type)
  end
end
