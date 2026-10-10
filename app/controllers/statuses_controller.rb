class StatusesController < ApplicationController
  def show
    @owner = current_owner
    @user_status = @owner.user_status
  end
end
