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

    form.name = params[:name]
    form.submission_email = params[:submission_email]

    form.save

    flash[:message] = 'Successfully created!'
    redirect_to :root
  rescue StandardError
    flash[:message] = 'Unsuccessful'
    render :edit
  end

  def destroy
    form = Form.find(params[:id])
    form.destroy

    flash[:message] = "Successfully deleted #{form.name}"
    redirect_to root_path, status: :see_other
  rescue StandardError
    flash[:message] = 'Unsuccessful'
    render :edit
  end
end
