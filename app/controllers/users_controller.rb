class UsersController < ApplicationController
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  rescue_from ActiveRecord::RecordNotFound do
    render template: "errors/not_found", status: :not_found
  end

  def index
    authorize current_user, :can_manage_user?
    render template: "users/index", locals: { users: policy_scope(User) }
  end

  def edit
    authorize current_user, :can_manage_user?
    user
  end

  def update
    authorize current_user, :can_manage_user?

    if user.update(user_params)
      user.update_user_forms
      redirect_to users_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def user_params
    params.require(:user).permit(:has_access, :role, :organisation_id).tap do |p|
      # We have to take steps to detect when the autocomplete compoenent is
      # empty. We use the value of rawAttribute, which is the text input when JS
      # is enabled. When it's empty, the user has cleared it. This isn't needed
      # when the no JS select is used but we have to allow organisation_id to be
      # nil still.
      if p.key?(:organisation_id) && organisation_id_raw && organisation_id_raw.empty?
        p[:organisation_id] = nil
      end
    end
  end

  def user
    @user ||= User.find(params[:id])
  end

  def organisation_id_raw
    params.dig(:user, :organisation_id_raw)
  end
end
