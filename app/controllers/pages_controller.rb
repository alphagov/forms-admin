class PagesController < ApplicationController
  before_action :check_user_has_permission
  before_action :clear_draft_questions_data, only: %i[index move_page]
  after_action :verify_authorized

  def index
    @pages = FormRepository.pages(current_form)
    @mark_complete_input = Forms::MarkPagesSectionCompleteInput.new(form: current_form).assign_form_values
    render :index, locals: { current_form: }
  end

  def delete
    @page = PageRepository.find(page_id: params[:page_id], form_id: current_form.id)
    @url = destroy_page_path(current_form.id, @page.id)
    @confirm_deletion_legend = t("forms_delete_confirmation_input.confirm_deletion_page")
    @item_name = @page.question_text
    @back_url = edit_question_path(current_form.id, @page.id)

    all_form_conditions = FormRepository.pages(current_form).flat_map(&:routing_conditions).compact_blank
    @page_goto_conditions = all_form_conditions.select { |condition| condition.goto_page_id == @page.id }

    if @page.routing_conditions.any? && @page.routing_conditions.first.secondary_skip?
      @routing = :start_of_secondary_skip_route

      # route page is condition check page
      @route_page = PageRepository.find(page_id: @page.routing_conditions.first.check_page_id, form_id: current_form.id)
    elsif @page.routing_conditions.any?
      @routing = :start_of_route

      # route page is us
      @route_page = @page
    elsif @page_goto_conditions.any? && @page_goto_conditions.first.secondary_skip?
      @routing = :end_of_secondary_skip_route

      # route page is condition check page
      @route_page = PageRepository.find(page_id: @page_goto_conditions.first.check_page_id, form_id: current_form.id)
    elsif @page_goto_conditions.any?
      @routing = :end_of_route

      # route page is condition routing page
      @route_page = PageRepository.find(page_id: @page_goto_conditions.first.routing_page_id, form_id: current_form.id)
    end

    @delete_confirmation_input = Forms::DeleteConfirmationInput.new

    render locals: { current_form: }
  end

  def destroy
    @page = PageRepository.find(page_id: params[:page_id], form_id: current_form.id)
    @url = destroy_page_path(current_form.id, @page.id)
    @item_name = @page.question_text
    @back_url = edit_question_path(current_form.id, @page.id)

    @delete_confirmation_input = Forms::DeleteConfirmationInput.new(
      params.require(:forms_delete_confirmation_input).permit(:confirm),
    )
    if @delete_confirmation_input.valid?
      if @delete_confirmation_input.confirmed?
        delete_page(current_form.id, @page)
      else
        redirect_to @back_url
      end
    else
      render :delete, locals: { current_form: }
    end
  rescue StandardError
    flash[:message] = "Deletion unsuccessful"
    redirect_to @back_url
  end

  def start_new_question
    clear_draft_questions_data
    redirect_to type_of_answer_create_path(form_id: current_form.id)
  end

  def move_page
    page_to_move = PageRepository.find(page_id: move_params[:page_id], form_id: move_params[:form_id])

    PageRepository.move_page(page_to_move, move_params[:direction])

    position = if move_params[:direction] == :up
                 page_to_move.position - 1
               else
                 page_to_move.position + 1
               end

    redirect_to form_pages_path, success: t("banner.success.form.page_moved", question_text: page_to_move.question_text, direction: move_params[:direction], question_number: position)
  end

private

  def clear_draft_questions_data
    DraftQuestion.destroy_by(form_id: current_form.id, user_id: current_user.id) if current_user.present? && current_form.present?
  end

  def check_user_has_permission
    authorize current_form, :can_edit_form?
  end

  def page
    @page ||= PageRepository.find(page_id: params[:page_id], form_id: current_form.id)
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
      attributes = page.attributes
        .slice(*edit_draft_question.attribute_names)
        .except(:id)
      edit_draft_question.attributes = attributes
      edit_draft_question.save!(validate: false)
    end
    edit_draft_question
  end

  def delete_page(form, page)
    success_url = form_pages_path(form)

    if PageRepository.destroy(page)
      redirect_to success_url, status: :see_other, success: "Successfully deleted ‘#{page.question_text}’"
    else
      raise StandardError, "Deletion unsuccessful"
    end
  end
end
