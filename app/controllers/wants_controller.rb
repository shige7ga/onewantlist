class WantsController < ApplicationController
  before_action :authenticate_user!

  def show
    @want = Want.find(params[:id])
  end

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

  def edit
    @want = current_user.wants.find(params[:id])
  end

  def update
    @want = current_user.wants.find(params[:id])
    if @want.update(want_params)
      redirect_to want_path(@want), success: t("defaults.flash_message.updated", item: Want.model_name.human)
    else
      flash.now[:danger] = t("defaults.flash_message.not_updated", item: Want.model_name.human)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    want = current_user.wants.find(params[:id])
    want.destroy!
    redirect_to mypage_path, success: t("defaults.flash_message.deleted", item: Want.model_name.human), status: :see_other
  end

  private

  def want_params
    params.require(:want).permit(:content, :status, :due_date)
  end
end
