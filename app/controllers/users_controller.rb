class UsersController < WebController
  include Pagy::Backend

  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  rescue_from ActiveRecord::RecordNotFound do
    render template: "errors/not_found", status: :not_found
  end

  def index
    authorize current_user, :can_manage_user?

    users_query = policy_scope(User)
                   .by_name(filter_params[:name])
                   .by_email(filter_params[:email])
                   .by_organisation_id(filter_params[:organisation_id])
                   .by_role(filter_params[:role])
                   .by_has_access(filter_params[:has_access])
                   .for_users_list

    @pagy, @users = pagy(users_query, limit: 50)

    @filter_input = Users::FilterInput.new(filter_params)

    render template: "users/index"
  end

  def edit
    authorize current_user, :can_manage_user?
    user
  end

  def update
    authorize current_user, :can_manage_user?

    if UserUpdateService.new(user, user_params).update_user
      redirect_to users_path
    else
      render :edit, status: :unprocessable_content
    end
  end

private

  def user_params
    params.require(:user).permit(:has_access, :name, :role, :organisation_id).tap do |p|
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

  def filter_params
    params[:filter]&.permit(:name, :email, :organisation_id, :role, :has_access) || {}
  end
end
