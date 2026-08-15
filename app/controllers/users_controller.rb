class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @wants = current_user.wants.order(created_at: :desc)
  end
end
