class FormsController < ApplicationController
  def index
    @forms = Form.all
  end

  def new
    @form = Form.new
  end

  def create
    @form = Form.new(form_params)

    if @form.save
      redirect_to forms_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @form = Form.find(params[:id])
  end

  def update
    @form = Form.find(params[:id])

    if @form.update(form_params)
      redirect_to forms_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def form_params
      params.require(:form).permit(:title,:email)
    end
end
