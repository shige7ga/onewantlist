class Guest::UsersController < ApplicationController
  before_action :set_guest

  def show
    @user_status = @current_guest.user_status
    @wants = @current_guest.wants.order(created_at: :desc)
  end

  private

  def set_guest
    @current_guest = ensure_guest
  end
end
