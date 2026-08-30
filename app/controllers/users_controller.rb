class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @user_status = @user.user_status
    @wants = @user.wants.order(created_at: :desc)
  end
end
