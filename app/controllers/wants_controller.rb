class WantsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_today_want_registration, only: %i[ new create ]
  before_action :set_want, only: %i[ show edit update destroy ]

  def show
  end

  def new
    @want = current_user.wants.new
  end

  def create
    @want = current_user.wants.new(want_params)
    if @want.save
      add_status_events(current_user.user_status.record_want_registration!)
      redirect_to mypage_path, notice: t("defaults.flash_message.created", item: Want.model_name.human)
    else
      flash.now[:alert] = t("defaults.flash_message.not_created", item: Want.model_name.human)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @want.update(want_params)
      redirect_to want_path(@want), notice: t("defaults.flash_message.updated", item: Want.model_name.human)
    else
      flash.now[:danger] = t("defaults.flash_message.not_updated", item: Want.model_name.human)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @want.destroy!
    redirect_to mypage_path, notice: t("defaults.flash_message.deleted", item: Want.model_name.human), status: :see_other
  end

  private

  def check_today_want_registration
    return unless current_user.user_status.last_want_registration_date == Date.current

    redirect_to mypage_path, alert: "今日は既にやりたいことを登録完了しています"
  end

  def want_params
    params.require(:want).permit(:content, :status, :due_date)
  end

  def set_want
    @want = current_user.wants.find_by(id: params[:id])
    return if @want.present?
    redirect_to mypage_path, alert: "アクセス権がありません"
  end
end
