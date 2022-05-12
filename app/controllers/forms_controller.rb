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
end
