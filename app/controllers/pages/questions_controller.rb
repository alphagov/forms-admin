class Pages::QuestionsController < PagesController
  def new
    answer_type = draft_question.answer_type
    question_text = session.dig(:page, :question_text)
    answer_settings = draft_question.answer_settings
    is_optional = session.dig(:page, :is_optional) == "true"
    page_heading = draft_question.page_heading
    guidance_markdown = draft_question.guidance_markdown
    @question_form = Pages::QuestionForm.new(form_id: current_form.id, answer_type:, question_text:, answer_settings:, is_optional:, draft_question:)

    @page = Page.new(form_id: current_form.id, question_text:, answer_type:, answer_settings:, is_optional:, page_heading:, guidance_markdown:)
    render :new, locals: { current_form: }
  end

  def create
    answer_settings = session.dig(:page, :answer_settings)
    page_heading = draft_question.page_heading
    guidance_markdown = draft_question.guidance_markdown

    @question_form = Pages::QuestionForm.new(page_params.merge(answer_settings:, page_heading:, guidance_markdown:, draft_question:))
    @page = Page.new(page_params.merge(answer_settings:, page_heading:, guidance_markdown:, answer_type: @question_form.draft_question.answer_type))

    # TODO: Move Page creation to be part of the form submit method
    if @question_form.submit && @page.save
      clear_questions_session_data
      handle_submit_action
    else
      render :new, locals: { current_form: }, status: :unprocessable_entity
    end
  end

  def edit
    reset_session_if_answer_settings_not_present
    page.load_from_session(session, %i[answer_settings is_optional])

    page.page_heading = draft_question.page_heading
    page.guidance_markdown = draft_question.guidance_markdown
    page.answer_type = draft_question.answer_type

    @question_form = Pages::QuestionForm.new(form_id: current_form.id,
                                             answer_type: page.answer_type,
                                             question_text: page.question_text,
                                             hint_text: page.hint_text,
                                             is_optional: page.is_optional,
                                             answer_settings: page.answer_settings)
    render :edit, locals: { current_form: }
  end

  def update
    page.load_from_session(session, %i[answer_settings]).load(page_params)
    page.page_heading = draft_question.page_heading
    page.guidance_markdown = draft_question.guidance_markdown
    page.answer_type = draft_question.answer_type
    page.answer_settings = draft_question.answer_settings

    @question_form = Pages::QuestionForm.new(page_params.merge(answer_settings: page.answer_settings,
                                                               page_heading: page.page_heading,
                                                               guidance_markdown: page.guidance_markdown,
                                                               draft_question:))

    # TODO: Move Page creation to be part of the form submit method
    if @question_form.submit && page.save
      clear_questions_session_data
      handle_submit_action
    else
      render :edit, locals: { current_form: }, status: :unprocessable_entity
    end
  end

private

  def page_params
    # TODO: Remove current_form from merge once we using draft question properly. the question form shouldn't need to know about form id
    params.require(:pages_question_form).permit(:question_text, :hint_text, :is_optional).merge(form_id: current_form.id)
  end

  def reset_session_if_answer_settings_not_present
    answer_type = draft_question.answer_type
    answer_settings = draft_question.answer_settings

    if (Page::ANSWER_TYPES_WITH_SETTINGS.include? answer_type) && (answer_settings.blank? || answer_settings == {})
      clear_questions_session_data
      redirect_to edit_question_path(params[:form_id], params[:page_id])
    end
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
