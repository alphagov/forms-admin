class PagesController < ApplicationController
  before_action :check_user_has_permission
  skip_before_action :clear_draft_questions_data, except: %i[index move_page]
  after_action :verify_authorized

  def index
    @pages = current_form.pages
    @mark_complete_form = Forms::MarkCompleteForm.new(form: current_form).assign_form_values
    render :index, locals: { current_form: }
  end

  def start_new_question
    clear_draft_questions_data
    redirect_to type_of_answer_create_path(form_id: current_form.id)
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
    authorize current_form, :can_view_form?
  end

  def page
    @page ||= Page.find(params[:page_id], params: { form_id: current_form.id })
  end

  def draft_question
    @draft_question ||= if params[:page_id].present?
                          setup_draft_question_for_existing_page
                        else
                          DraftQuestion.find_or_initialize_by(form_id: current_form.id, user_id: current_user.id)
                        end
  end

  def move_params
    form_id = params.require(:form_id)
    p = params.require(:move_direction).permit(%i[up down])
    direction = p[:up] ? :up : :down
    page_id = p[direction]
    @move_params ||= { form_id:, page_id:, direction: }
  end

  def setup_draft_question_for_existing_page
    edit_draft_question = DraftQuestion.find_or_initialize_by(form_id: current_form.id, user_id: current_user.id, page_id: page.id)

    if edit_draft_question.new_record?
      edit_draft_question.attributes = page.attributes.except(:id, :position, :next_page, :has_routing_errors, :routing_conditions, :question_with_text)
      edit_draft_question.save!(validate: false)
    end
    edit_draft_question
  end
end
