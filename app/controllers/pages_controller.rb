class PagesController < ApplicationController
  before_action :fetch_form, :answer_types, :convert_session_keys_to_symbols
  before_action :check_user_has_permission
  skip_before_action :clear_questions_session_data, except: %i[index move_page]
  after_action :verify_authorized

  def index
    @pages = @form.pages
    @mark_complete_form = Forms::MarkCompleteForm.new(form: @form).assign_form_values
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

  def fetch_form
    @form = Form.find(params[:form_id])
  end

  def page
    @page ||= Page.find(params[:page_id], params: { form_id: @form.id })
  end

  def move_params
    form_id = params.require(:form_id)
    p = params.require(:move_direction).permit(%i[up down])
    direction = p[:up] ? :up : :down
    page_id = p[direction]
    @move_params ||= { form_id:, page_id:, direction: }
  end

  def answer_types
    @answer_types = Page::ANSWER_TYPES
  end

  def convert_session_keys_to_symbols
    session[:page].deep_symbolize_keys! if session[:page].present?
  end
end
