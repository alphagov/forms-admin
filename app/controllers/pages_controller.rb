class PagesController < ApplicationController
  def index
    @form = Form.find(params[:form_id])
    @pages = @form.pages
  end

  def new
    @form = Form.find(params[:form_id])
    @page = Page.new(form_id: @form.id)
    @page_number = @form.pages.length + 1
  end

  def create
    @form = Form.find(params[:form_id])
    @page = Page.new(page_params(@form.id))
    @page_number = @form.pages.length + 1

    if @page.save
      redirect_to action: "index", form_id: @form.id
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @form = Form.find(params[:form_id])
    @page = Page.find(params[:id], params: { form_id: @form.id })
    @page_number = @form.pages.index(@page) + 1
  end

  def update
    @form = Form.find(params[:form_id])
    @page = Page.find(params[:id], params: { form_id: @form.id })
    @page_number = @form.pages.index(@page) + 1

    @page.load(page_params(@form.id))

    if @page.save
      redirect_to action: "index", form_id: @form.id
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def page_params(form_id)
    params.require(:page).permit(:question_text, :question_short_name, :hint_text, :answer_type).merge(form_id: form_id)
  end
end
