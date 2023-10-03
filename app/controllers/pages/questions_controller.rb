class Pages::QuestionsController < PagesController
  def new
    answer_type = session.dig(:page, :answer_type)
    question_text = session.dig(:page, :question_text)
    answer_settings = session.dig(:page, :answer_settings)
    is_optional = session.dig(:page, :is_optional) == "true"
    page_heading = session.dig(:page, :page_heading)
    guidance_markdown = session.dig(:page, :guidance_markdown)
    @question_form = Pages::QuestionForm.new(form_id: @form.id, answer_type:, question_text:, answer_settings:, is_optional:)
    @page = Page.new(form_id: @form.id, question_text:, answer_type:, answer_settings:, is_optional:, page_heading:, guidance_markdown:)

    render "pages/new"
  end

  def create
    answer_settings = session.dig(:page, :answer_settings)
    page_heading = session.dig(:page, :page_heading)
    guidance_markdown = session.dig(:page, :guidance_markdown)

    @page = Page.new(page_params.merge(answer_settings:, page_heading:, guidance_markdown:))

    @question_form = Pages::QuestionForm.new(page_params.merge(answer_settings:, page_heading:, guidance_markdown:))
    if @question_form.valid? && @page.save
      clear_questions_session_data
      handle_submit_action
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    reset_session_if_answer_settings_not_present
    page.load_from_session(session, %i[answer_settings answer_type is_optional page_heading guidance_markdown])

    @question_form = Pages::QuestionForm.new(form_id: @form.id,
                                             answer_type: page.answer_type,
                                             question_text: page.question_text,
                                             hint_text: page.hint_text,
                                             is_optional: page.is_optional,
                                             answer_settings: page.answer_settings)
  end

  def update
    page.load_from_session(session, %i[answer_type answer_settings page_heading guidance_markdown]).load(page_params)

    if page.save
      clear_questions_session_data
      handle_submit_action
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def page_params
    params.require(:pages_question_form).permit(:question_text, :hint_text, :answer_type, :is_optional).merge(form_id: @form.id)
  end

  def reset_session_if_answer_settings_not_present
    answer_type = session.dig(:page, :answer_type)
    answer_settings = session.dig(:page, :answer_settings)

    if (Page::ANSWER_TYPES_WITH_SETTINGS.include? answer_type) && (answer_settings.blank? || answer_settings == {})
      clear_questions_session_data
      redirect_to edit_question_path(params[:form_id], params[:page_id])
    end
  end

  def handle_submit_action
    # if user chose to save and reload current page
    return redirect_to edit_question_path(@form, @page), success: "Your changes have been saved" if params[:save_preview]

    return redirect_to delete_page_path(@form, @page) if params[:delete]

    # Default: either edit the next page or create a new one
    if @page.has_next_page?
      redirect_to edit_question_path(@form, @page.next_page)
    else
      redirect_to type_of_answer_new_path(@form)
    end
  end
end
