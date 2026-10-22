class WantsController < ApplicationController
  before_action :check_guest_registration_limit, only: :new
  before_action :redirect_if_want_registered_today, only: :new
  before_action :set_want, only: %i[ show edit update destroy ]

  def show
  end

  def new
    @want = current_owner.wants.new
  end

  def create
    source = registration_source

    result = Wants::Register.new(
      owner: current_owner,
      attributes: want_params,
      source: source
    ).call

    @want = result.want

    case result.error
    when nil
      session.delete(:random_want_id) if source == :gacha
      add_status_events(result.events)

      redirect_to owner_home_path,
                  notice: t("defaults.flash_message.created",
                            item: Want.model_name.human)

    when :already_registered
      redirect_to owner_home_path,
                  alert: "今日は既にやりたいことを登録完了しています"

    when :guest_limit
      redirect_to new_user_registration_path,
                  alert: "ゲスト体験上限に達しました。ユーザー登録して使ってみましょう。"

    else
      flash.now[:alert] = t("defaults.flash_message.not_created",
                            item: Want.model_name.human)

      if source == :gacha
        render "random_wants/edit", status: :unprocessable_entity
      else
        render :new, status: :unprocessable_entity
      end
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

  def registration_source
    @registration_source ||=
      case params[:registration_source]
      when "gacha"
        raise ArgumentError, "Missing random_want session" if session[:random_want_id].blank?
        :gacha
      when "direct"
        :direct
      else
        raise ArgumentError, "Unknown registration_source: #{params[:registration_source].inspect}"
      end
  end

  def check_guest_registration_limit
    return if user_signed_in?
    return unless current_owner.direct_registration_limit_reached?

    redirect_to new_user_registration_path, alert: "ゲスト体験上限に達しました。ユーザー登録して使ってみましょう。"
  end

  def record_guest_registration!
    return if user_signed_in?
    return unless registration_source == :direct

    current_owner.record_direct_registration!
  end

  def want_params
    params.require(:want).permit(:content, :status, :due_date)
  end

  def set_want
    @want = current_owner.wants.find_by(id: params[:id])
    return if @want.present?
    redirect_to owner_home_path, alert: "アクセス権がありません"
  end
end
