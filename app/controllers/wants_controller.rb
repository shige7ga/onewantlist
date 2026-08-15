class WantsController < ApplicationController
  before_action :authenticate_user!

  def new
    @want = current_user.wants.new
  end

  def create
    @want = current_user.wants.new(want_params)
    if @want.save
      redirect_to mypage_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def want_params
    params.require(:want).permit(:content)
  end
end
