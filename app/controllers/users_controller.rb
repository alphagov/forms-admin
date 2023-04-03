class UsersController < ApplicationController
  def index
    render template: "users/index", locals: { users: User.all}
  end
end
