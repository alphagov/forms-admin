class PagesController < ApplicationController
  before_action :fetch_form, :answer_types, :convert_session_keys_to_symbols
  before_action :check_user_has_permission
  skip_before_action :clear_questions_session_data, except: %i[index move_page]
  after_action :verify_authorized

  def index
    @pages = @form.pages
    @mark_complete_form = Forms::MarkCompleteForm.new(form: @form).assign_form_values
  end

  def new
    @question_form = Pages::QuestionForm.new(question_text: draft_question.question_text,
                                             hint_text: draft_question.hint_text,
                                             is_optional: draft_question.is_optional,
                                             answer_type: draft_question.answer_type)

    @page = Page.new(answer_settings: draft_question.answer_settings,
                     page_heading: draft_question.page_heading,
                     guidance_markdown: draft_question.guidance_markdown)
  end

  def create
    # Setup Form object
    @question_form = Pages::QuestionForm.new(page_params)

    if @question_form.submit
      # Setup new Page instance
      @page = Page.new(form_id: draft_question.form_id,
                       question_text: draft_question.question_text,
                       hint_text: draft_question.hint_text,
                       answer_type: draft_question.answer_type,
                       is_optional: draft_question.is_optional,
                       answer_settings: draft_question.answer_settings,
                       page_heading: draft_question.page_heading,
                       guidance_markdown: draft_question.guidance_markdown)

      # Save to Draft Questions & Save to forms-api

      # draft_question.attributes = page_params.except(:draft_question)

      if @page.save
        draft_question.destroy!
        handle_submit_action
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def edit
    # reset_session_if_answer_settings_not_present

    @question_form = Pages::QuestionForm.new(question_text: draft_question.question_text,
                                             hint_text: draft_question.hint_text,
                                             is_optional: draft_question.is_optional,
                                             answer_type: draft_question.answer_type)

    page
  end

  def update
    # Setup Form object
    @question_form = Pages::QuestionForm.new(page_params)
    page

    if @question_form.submit

      page.attributes = { question_text: draft_question.question_text,
                          hint_text: draft_question.hint_text,
                          answer_type: draft_question.answer_type,
                          is_optional: draft_question.is_optional,
                          answer_settings: draft_question.answer_settings,
                          page_heading: draft_question.page_heading,
                          guidance_markdown: draft_question.guidance_markdown }
      if page.save
        draft_question.destroy!
        handle_submit_action
      else
        render :edit, status: :unprocessable_entity
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def move_page
    page_to_move = Page.find(move_params[:page_id], params: { form_id: move_params[:form_id] })

    page_to_move.move_page(move_params[:direction])

    position = if move_params[:direction] == :up
                 page_to_move.position - 1
               else
                 page_to_move.position + 1
               end

    redirect_to form_pages_path, success: t("banner.success.form.page_moved", question_text: page_to_move.question_text, direction: move_params[:direction], position:)
  end

private

  def check_user_has_permission
    authorize @form, :can_view_form?
  end

  def page_params
    params.require(:pages_question_form).permit(:question_text, :hint_text, :is_optional).merge(draft_question:)
  end

  def fetch_form
    @form = Form.find(params[:form_id])
  end

  def page
    @page ||= Page.find(params[:page_id], params: { form_id: @form.id })
  end

  def draft_question
    @draft_question ||= if params[:page_id].present?
                          setup_draft_question_for_existing_page
                        else
                          DraftQuestion.find_or_initialize_by(form_id: @form.id, user_id: current_user.id)
                        end
  end

  def move_params
    form_id = params.require(:form_id)
    p = params.require(:move_direction).permit(%i[up down])
    direction = p[:up] ? :up : :down
    page_id = p[direction]
    @move_params ||= { form_id:, page_id:, direction: }
  end

  def reset_session_if_answer_settings_not_present
    answer_type = session.dig(:page, :answer_type)
    answer_settings = session.dig(:page, :answer_settings)

    if (Page::ANSWER_TYPES_WITH_SETTINGS.include? answer_type) && (answer_settings.blank? || answer_settings == {})
      clear_questions_session_data
      redirect_to edit_page_path(params[:form_id], params[:page_id])
    end
  end

  def handle_submit_action
    # if user chose to save and reload current page
    return redirect_to edit_page_path(@form, @page), success: "Your changes have been saved" if params[:save_preview]

    return redirect_to delete_page_path(@form, @page) if params[:delete]

    # Default: either edit the next page or create a new one
    if @page.has_next_page?
      redirect_to edit_page_path(@form, @page.next_page)
    else
      redirect_to type_of_answer_new_path(@form)
    end
  end

  def answer_types
    @answer_types = Page::ANSWER_TYPES
  end

  def convert_session_keys_to_symbols
    session[:page].deep_symbolize_keys! if session[:page].present?
  end

  def setup_draft_question_for_existing_page
    edit_draft_question = DraftQuestion.find_or_initialize_by(form_id: @form.id, user_id: current_user.id, page_id: page.id)

    if edit_draft_question.new_record?
      edit_draft_question.attributes = page.attributes.except(:position, :next_page, :has_routing_errors, :routing_conditions, :question_with_text)
      edit_draft_question.save!(validate: false)
    end
    edit_draft_question
  end
end
