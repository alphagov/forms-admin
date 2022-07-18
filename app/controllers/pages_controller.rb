class PagesController < ApplicationController
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
      if @page_number > 1
        page_to_update = previous_last_page
        page_to_update.next = @page.id
        page_to_update.save!
      end

      redirect_to form_path(@form)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @form = Form.find(params[:form_id])
    @page = Page.find(params[:page_id], params: { form_id: @form.id })
    @page_number = @form.pages.index(@page) + 1
  end

  def update
    @form = Form.find(params[:form_id])
    @page = Page.find(params[:page_id], params: { form_id: @form.id })
    @page_number = @form.pages.index(@page) + 1

    @page.load(page_params(@form.id))

    if @page.save
      redirect_to form_path(@form)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def delete
    @form = Form.find(params[:form_id])
    @page = Page.find(params[:page_id], params: { form_id: @form.id })
  end

  def destroy
    @form = Form.find(params[:form_id])
    @page = Page.find(params[:page_id], params: { form_id: @form.id })
    if @page.destroy
      flash[:message] = "Successfully deleted page"
      redirect_to form_path(params[:form_id]), status: :see_other
    else
      raise StandardError, "Deletion unsuccessful"
    end
  rescue StandardError
    flash[:message] = "Deletion unsuccessful"
    render :edit, status: :unprocessable_entity
  end

private

  def previous_last_page
    @form.pages.find { |p| !p.has_next? }
  end

  def page_params(form_id)
    params.require(:page).permit(:question_text, :question_short_name, :hint_text, :answer_type).merge(form_id:)
  end
end
