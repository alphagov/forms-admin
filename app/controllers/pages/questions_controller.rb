class Pages::QuestionsController < PagesController
  def new
    answer_type = draft_question.answer_type
    question_text = draft_question.question_text
    answer_settings = draft_question.answer_settings
    is_optional = draft_question.is_optional == "true"
    page_heading = draft_question.page_heading
    guidance_markdown = draft_question.guidance_markdown
    @question_form = Pages::QuestionForm.new(answer_type:, question_text:, answer_settings:, is_optional:, draft_question:)

    # TODO: Remove this once we have a check your question view. The new view should also pull data directly from draft_question instead of through page model
    @page = Page.new(form_id: current_form.id,
                     answer_type:,
                     answer_settings:,
                     is_optional:,
                     page_heading:,
                     guidance_markdown:)

    render :new, locals: { current_form: }
  end

  def create
    @question_form = Pages::QuestionForm.new(page_params.merge(page_params_for_form_object))

    @page = Page.new(page_params_for_forms_api)

    # TODO: Move Page creation to be part of the form submit method
    if @question_form.submit && @page.save
      clear_draft_questions_data
      handle_submit_action
    else
      render :new, locals: { current_form: }, status: :unprocessable_entity
    end
  end

  def edit
    @question_form = Pages::QuestionForm.new(answer_type: draft_question.answer_type,
                                             question_text: draft_question.question_text,
                                             hint_text: draft_question.hint_text,
                                             is_optional: draft_question.is_optional,
                                             answer_settings: draft_question.answer_settings)

    # TODO: Remove this once we have a check your question view. The new view should also pull data directly from draft_question instead of through page model
    page.answer_type = draft_question.answer_type
    page.answer_settings = draft_question.answer_settings
    page.is_optional = draft_question.is_optional
    page.page_heading = draft_question.page_heading
    page.guidance_markdown = draft_question.guidance_markdown

    render :edit, locals: { current_form: }
  end

  def update
    page.load(page_params_for_forms_api)

    @question_form = Pages::QuestionForm.new(page_params_for_form_object)

    # TODO: Move Page creation to be part of the form submit method
    if @question_form.submit && page.save
      clear_draft_questions_data
      handle_submit_action
    else
      render :edit, locals: { current_form: }, status: :unprocessable_entity
    end
  end

private

  def page_params
    params.require(:pages_question_form).permit(:question_text, :hint_text, :is_optional)
  end

  def page_params_for_form_object
    page_params.merge(draft_question:,
                      answer_type: draft_question.answer_type,
                      answer_settings: draft_question.answer_settings,
                      page_heading: draft_question.page_heading,
                      guidance_markdown: draft_question.guidance_markdown)
  end

  def page_params_for_forms_api
    page_params.merge(form_id: current_form.id,
                      answer_settings: draft_question.answer_settings,
                      page_heading: draft_question.page_heading,
                      guidance_markdown: draft_question.guidance_markdown,
                      answer_type: draft_question.answer_type)
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
