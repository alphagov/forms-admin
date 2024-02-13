class Pages::QuestionsController < PagesController
  before_action do
    raise "No answer type set for draft question" if draft_question.answer_type.blank?
  end

  def new
    @question_form = Pages::QuestionForm.new(answer_type: draft_question.answer_type,
                                             question_text: draft_question.question_text,
                                             answer_settings: draft_question.answer_settings,
                                             is_optional: draft_question.is_optional,
                                             draft_question:)

    # TODO: Remove this once we have a check your question view. The new view should also pull data directly from draft_question instead of through page model
    @page = Page.new(form_id: current_form.id)
    render :new, locals: { current_form:, draft_question: }
  end

  def create
    @question_form = Pages::QuestionForm.new(page_params_for_form_object)

    @page = Page.new(page_params_for_forms_api)

    # TODO: Move Page creation to be part of the form submit method
    if @question_form.submit && @page.save
      clear_draft_questions_data
      redirect_to edit_question_path(current_form, @page), success: "Your changes have been saved"
    else
      render :new, locals: { current_form:, draft_question: }, status: :unprocessable_entity
    end
  end

  def edit
    @question_form = Pages::QuestionForm.new(answer_type: draft_question.answer_type,
                                             question_text: draft_question.question_text,
                                             hint_text: draft_question.hint_text,
                                             is_optional: draft_question.is_optional,
                                             answer_settings: draft_question.answer_settings)
    render :edit, locals: { current_form:, draft_question: }
  end

  def update
    page.load(page_params_for_forms_api)

    @question_form = Pages::QuestionForm.new(page_params_for_form_object)

    # TODO: Move Page creation to be part of the form submit method
    if @question_form.submit && page.save
      clear_draft_questions_data
      redirect_to edit_question_path(current_form, @page), success: "Your changes have been saved"
    else
      render :edit, locals: { current_form:, draft_question: }, status: :unprocessable_entity
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
end
