class Pages::QuestionsController < PagesController
  def new
    @question_form = Pages::QuestionForm.new(form_id: current_form.id,
                                             answer_type: draft_question.answer_type,
                                             question_text: draft_question.question_text,
                                             answer_settings: draft_question.answer_settings,
                                             is_optional: draft_question.is_optional,
                                             draft_question:)

    @page = Page.new(form_id: current_form.id)
    render :new, locals: { current_form:, draft_question: }
  end

  def create
    @question_form = Pages::QuestionForm.new(page_params.merge(answer_settings: draft_question.answer_settings,
                                                               page_heading: draft_question.page_heading,
                                                               guidance_markdown: draft_question.guidance_markdown,
                                                               draft_question:))
    @page = Page.new(page_params.merge(answer_settings: draft_question.answer_settings,
                                       page_heading: draft_question.page_heading,
                                       guidance_markdown: draft_question.guidance_markdown,
                                       answer_type: draft_question.answer_type))

    # TODO: Move Page creation to be part of the form submit method
    if @question_form.submit && @page.save
      clear_questions_session_data
      handle_submit_action
    else
      render :new, locals: { current_form:, draft_question: }, status: :unprocessable_entity
    end
  end

  def edit
    @question_form = Pages::QuestionForm.new(form_id: current_form.id,
                                             answer_type: draft_question.answer_type,
                                             question_text: draft_question.question_text,
                                             hint_text: draft_question.hint_text,
                                             is_optional: draft_question.is_optional,
                                             answer_settings: draft_question.answer_settings)
    render :edit, locals: { current_form:, draft_question: }
  end

  def update
    page.load(page_params)
    page.page_heading = draft_question.page_heading
    page.guidance_markdown = draft_question.guidance_markdown
    page.answer_type = draft_question.answer_type
    page.answer_settings = draft_question.answer_settings

    @question_form = Pages::QuestionForm.new(page_params.merge(answer_settings: draft_question.answer_settings,
                                                               page_heading: draft_question.page_heading,
                                                               guidance_markdown: draft_question.guidance_markdown,
                                                               draft_question:))

    # TODO: Move Page creation to be part of the form submit method
    if @question_form.submit && page.save
      clear_questions_session_data
      handle_submit_action
    else
      render :edit, locals: { current_form:, draft_question: }, status: :unprocessable_entity
    end
  end

private

  def page_params
    # TODO: Remove current_form from merge once we using draft question properly. the question form shouldn't need to know about form id
    params.require(:pages_question_form).permit(:question_text, :hint_text, :is_optional).merge(form_id: current_form.id)
  end

  def handle_submit_action
    # if user chose to save and reload current page
    return redirect_to edit_question_path(current_form, @page), success: "Your changes have been saved" if params[:save_preview]

    return redirect_to delete_page_path(current_form, @page) if params[:delete]

    # Default: either edit the next page or create a new one
    if @page.has_next_page?
      redirect_to edit_question_path(current_form, @page.next_page)
    else
      redirect_to type_of_answer_new_path(current_form)
    end
  end
end
