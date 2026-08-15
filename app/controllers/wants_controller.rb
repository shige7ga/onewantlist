class WantsController < ApplicationController
  before_action :authenticate_user!

  def index
    @wants = current_user.wants
  end

  def new
    @want = current_user.wants.new
  end

  def create
    @want = current_user.wants.new(want_params)
    if @want.save
      redirect_to wants_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def want_params
    params.require(:want).permit(:content)
  end
end
