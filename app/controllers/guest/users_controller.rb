class Guest::UsersController < ApplicationController
  before_action :set_guest

  def show
    @user_status = @current_guest.user_status
    @wants = @current_guest.wants.order(created_at: :desc)

    @guest_limit_modal_type = session.delete(:guest_limit_modal_type)
  end

  private

  def set_guest
    @current_guest = ensure_guest
  end
end
