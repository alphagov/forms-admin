class FormsController < ApplicationController
  def new; end

  def create
    form = Form.new({
                      name: params[:name],
                      submission_email: params[:submission_email]
                    })

    form.save

    flash[:message] = 'Successfully created!'
    redirect_to :root
  rescue StandardError
    flash[:message] = 'Unsuccessful'
    render :new
  end

  def edit
    @form = Form.find(params[:id])
  end

  def update
    form = Form.find(params[:id])

    binding.pry
    form.name = form_params[:name]
    form.submission_email = form_params[:submission_email]

    form.save

    flash[:message] = 'Successfully created!'
    redirect_to :root
  rescue StandardError
    flash[:message] = 'Unsuccessful'
    redirect_to :edit_form, id: params[:id]
  end

private
  def form_params
    params.require(:form).permit(:name, :submission_email)
  end
end
