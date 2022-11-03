class PagesController < ApplicationController
  include CheckFormOrganisation
  before_action :fetch_form, :answer_types

  def new
    @page = Page.new(form_id: @form.id)
  end

  def index
    @form = Form.find(params[:form_id])
    @pages = @form.pages
    if FeatureService.enabled?(:task_list_statuses)
      @mark_complete_form = Forms::MarkCompleteForm.new(form: @form).assign_form_values
      @mark_complete_options = mark_complete_options
    end
  end

  def create
    @page = Page.new(page_params(@form.id))

    # if @form.save_page(@page)
    if @page.save
      handle_submit_action
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @page = Page.find(params[:page_id], params: { form_id: @form.id })
  end

  def update
    @page = Page.find(params[:page_id], params: { form_id: @form.id })

    @page.load(page_params(@form.id))

    if @page.save
      handle_submit_action
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def mark_complete
    if FeatureService.enabled?(:task_list_statuses)
      @form = Form.find(params[:form_id])
      @pages = @form.pages
      @mark_complete_form = Forms::MarkCompleteForm.new(mark_complete_form_params)
      @mark_complete_options = mark_complete_options

      if @mark_complete_form.valid?
        @form.question_section_completed = @mark_complete_form.mark_complete
        if @form.save
          redirect_to form_path(@form)
        else
          raise StandardError, "Save unsuccessful"
        end
      else
        render :index, status: :unprocessable_entity
      end
    end
  rescue StandardError => e
    flash[:message] = e
    render :index, status: :unprocessable_entity
  end

private

  def page_params(form_id)
    params.require(:page).permit(:question_text, :question_short_name, :hint_text, :answer_type, :is_optional).merge(form_id:)
  end

  def fetch_form
    @form = Form.find(params[:form_id])
  end

  def handle_submit_action
    # if user chose to save and reload current page
    return redirect_to edit_page_path(@form, @page) if params[:save_preview]

    return redirect_to delete_page_path(@form, @page) if params[:delete]

    # Default: either edit the next page or create a new one
    if @page.has_next_page?
      redirect_to edit_page_path(@form, @page.next_page)
    else
      redirect_to new_page_path(@form)
    end
  end

  def answer_types
    @answer_types = Page::ANSWER_TYPES
  end

  if FeatureService.enabled?(:task_list_statuses)
    def mark_complete_options
      [OpenStruct.new(value: "true"), OpenStruct.new(value: "false")]
    end

    def mark_complete_form_params
      params.require(:forms_mark_complete_form).permit(:mark_complete)
    end
  end
end
