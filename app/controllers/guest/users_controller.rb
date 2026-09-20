class Guest::UsersController < ApplicationController
  before_action :ensure_guest

  def show
    @user = current_guest
    @user_status = @user.user_status
    @wants = @user.wants
  end
end
