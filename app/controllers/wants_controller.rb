class WantsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_today_registration, only: %i[ new create ]

  def show
    @want = Want.find(params[:id])
  end

  def new
    @want = current_user.wants.new
  end

  def create
    @want = current_user.wants.new(want_params)
    if @want.save
      current_user.user_status.update(last_registration_date: Date.current)
      redirect_to mypage_path, notice: t("defaults.flash_message.created", item: Want.model_name.human)
    else
      flash.now[:alert] = t("defaults.flash_message.not_created", item: Want.model_name.human)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @want = current_user.wants.find(params[:id])
  end

  def update
    @want = current_user.wants.find(params[:id])
    if @want.update(want_params)
      redirect_to want_path(@want), notice: t("defaults.flash_message.updated", item: Want.model_name.human)
    else
      flash.now[:danger] = t("defaults.flash_message.not_updated", item: Want.model_name.human)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    want = current_user.wants.find(params[:id])
    want.destroy!
    redirect_to mypage_path, notice: t("defaults.flash_message.deleted", item: Want.model_name.human), status: :see_other
  end

  private

  def check_today_registration
    return unless current_user.user_status.last_registration_date == Date.current

    redirect_to mypage_path, alert: "今日は既にやりたいことを登録完了しています"
  end

  def want_params
    params.require(:want).permit(:content, :status, :due_date)
  end
end
