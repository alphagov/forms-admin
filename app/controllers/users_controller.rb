class UsersController < ApplicationController
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    authorize current_user, :can_manage_user?
    render template: "users/index", locals: { users: policy_scope(User) }
  end
end
