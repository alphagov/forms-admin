class PagesController < ApplicationController
  before_action :fetch_form, :answer_types

  def new
    @page = Page.new(form_id: @form.id)
  end

  def index
    @form = Form.find(params[:form_id])
    @pages = @form.pages
    @form_is_live = @form.live_at && @form.live_at < Time.now
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

private

  def page_params(form_id)
    params.require(:page).permit(:question_text, :question_short_name, :hint_text, :answer_type).merge(form_id:)
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
    @answer_types = %w[single_line address date email national_insurance_number phone_number]
  end
end
